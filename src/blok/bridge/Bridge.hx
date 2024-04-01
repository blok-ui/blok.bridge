package blok.bridge;

import blok.bridge.asset.*;
import blok.bridge.project.*;
import blok.bridge.project.loader.*;
import blok.context.Provider;
import blok.html.Server;
import blok.html.server.*;
import blok.router.*;
import blok.suspense.SuspenseBoundary;
import blok.ui.*;
import kit.file.FileSystem;
import kit.file.adaptor.SysAdaptor;

class Bridge {
  /**
    Start your Bridge app using a project.toml for configuration. This is
    the recommended way to use Blok Bridge.

    Note that this method expects to find a project.toml at the root
    of the current working directory (cwd). If that's not how you have 
    things set up, you may need to use a custom ProjectLoader and
    kit.file.FileSystem instance.
  **/
  public static function start(render):Task<Bridge> {
    var fs = new FileSystem(new SysAdaptor(Sys.getCwd()));
    var loader = new TomlProjectLoader(fs);
    return fromLoader(loader, render, fs);
  }

  /**
    Start your app using a custom loader for your project configuration.
  **/
  public static function fromLoader(loader:ProjectLoader, render, ?fs) {
    return loader
      .load()
      .next(project -> new Bridge(project, render, fs));
  }

  final project:Project;
  final render:()->Child;
  final fs:FileSystem;

  public function new(project, render, ?fs) {
    this.project = project;
    this.render = render;
    this.fs = fs ?? new FileSystem(new SysAdaptor(Sys.getCwd()));
  }

  public function generate():Task<AppContext> {
    var app = new AppContext(project, fs.directory(project.paths.publicDirectory));
    var islands = new IslandContext();
    var visitor = new RouteVisitor();

    app.addAsset(new ClientAppAsset(fs, project, islands));
    visitor.enqueue('/');

    return renderUntilComplete(app, islands, visitor).next(documents -> {
      for (asset in documents) app.addAsset(asset);
      return app;
    });
  }

  function renderUntilComplete(
    assets:AppContext,
    islands:IslandContext,
    visitor:RouteVisitor
  ):Task<Array<HtmlAsset>> {
    var paths = visitor.drain();
    return Task
      .parallel(...paths.map(path -> renderPath(path, assets, islands, visitor)))
      .next(documents -> {
        if (visitor.hasPending()) {
          return renderUntilComplete(assets, islands, visitor)
            .next(moreDocuments -> documents.concat(moreDocuments));
        }
        return documents;
      });
  }
  
  function renderPath(
    path:String,
    assets:AppContext,
    islands:IslandContext,
    visitor:RouteVisitor
  ):Task<HtmlAsset> {
    return new Task(activate -> {
      var document = new Element('#document', {});
      var root:Null<View> = null;
      var suspended = false;
      var activated = false;

      function checkActivation() {
        if (activated) throw 'Activated more than once on a render';
        activated = true;
      }

      function sendHtml(path:String, document:Element) {
        var html = new HtmlAsset(path, document.toString());

        root?.dispose();
        activate(Ok(html));
      }

      root = mount(document, () -> Provider
        .provide(() -> assets)
        .provide(() -> islands)
        .provide(() -> visitor)
        .provide(() -> new Navigator({ url: path }))
        .child(_ -> SuspenseBoundary.node({
          child: render(),
          onSuspended: () -> suspended = true,
          onComplete: () -> {
            checkActivation();
            sendHtml(path, document);
          },
          fallback: () -> Placeholder.node()
        }))
      );

      if (suspended == false) {
        checkActivation();
        sendHtml(path, document);
      }
    });
  }
}
