package blok.bridge;

import blok.suspense.SuspenseBoundary;
import blok.context.*;
import blok.ui.*;
import blok.html.*;

#if blok.server
import blok.bridge.server.*;
#else
import blok.bridge.client.*;
#end

enum AppNameStrategy {
  Skip;
  Custom(path:String);
  FromCompiler(?name:String);
}

enum HydrationStrategy {
  Skip;
  Collect(id:String);
  IslandsOnly;
}

typedef BridgeOptions = {
  public final rootId:String;
  public final ?appNameStrategy:AppNameStrategy;
  public final ?hydrationStrategy:HydrationStrategy;
}

// @todo: This is a mess right now.
class Bridge {
  public final apis:ApiCollection;
  public final options:BridgeOptions;
  
  final render:(bridge:Bridge)->Child;

  public function new(apis, render, ?options:BridgeOptions) {
    this.apis = new ApiCollection(apis);
    this.render = render;
    this.options = options ?? { rootId: 'root' };
  }

  public function mount():Task<Document> {
    var doc = createDocument();
    return new Future<Result<Document>>(activate -> {
      var suspended:Bool = false;
      createRoot(doc, () -> SuspenseBoundary.node({
        onSuspended: () -> suspended = true,
        onComplete: () -> activate(Ok(doc)),
        fallback: () -> 'loading...', // @todo: Some new default
        child: renderRoot()
      }));
      if (!suspended) activate(Ok(doc));
    });
  }

  function renderRoot() {
    return Provider.compose(apis, _ -> render(this));
  }

  #if blok.server
  public function serve() {
    #if nodejs
    // @todo: need configuration.
    var server = new kit.http.server.NodeServer(3000);
    var handler = createMiddleware().apply(new BridgeHtmlHandler(this));
    server.serve(handler);
    #end
  }

  public function createMiddleware():BridgeApiMiddleware {
    return new BridgeApiMiddleware(this);
  }

  function createDocument():Document {
    return new ServerDocument({
      rootId: options.rootId
    });
  }

  function createRoot(document:Document, render) {
    Server.mount(document.getRootLayer(), render);
  }
  #else
  function createDocument():Document {
    return new ClientDocument({
      rootId: options.rootId
    });
  }

  function createRoot(document:Document, render) {
    // @todo
    Client.hydrate(document.getRootLayer(), render);
  }
  #end
}
