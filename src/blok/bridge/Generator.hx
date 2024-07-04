package blok.bridge;

import blok.bridge.asset.HtmlAsset;
import blok.context.Provider;
import blok.html.Server;
import blok.html.server.*;
import blok.router.*;
import blok.suspense.SuspenseBoundary;
import blok.ui.*;
import kit.file.FileSystem;
import kit.file.adaptor.SysAdaptor;

using Lambda;

// @todo: Ideally we could do cool things with threads here, but for now...
class Generator {
	final config:AppConfig;
	final render:() -> Child;
	final fs:FileSystem;

	public function new(config, render, ?fs) {
		this.config = config;
		this.render = render;
		this.fs = fs ?? new FileSystem(new SysAdaptor(Sys.getCwd()));
	}

	public function generate():Task<AppContext> {
		var app = createAppContext();
		var visitor = new RouteVisitor();

		visitor.enqueue('/');

		return renderUntilComplete(app, visitor).next(documents -> {
			for (asset in documents) app.addAsset(asset);
			return app;
		});
	}

	public function generatePage(path:String):Task<{
		html:HtmlAsset,
		app:AppContext
	}> {
		var app = createAppContext();
		var visitor = new RouteVisitor();

		return renderPath(path, app, visitor).next(html -> {
			html: html,
			app: app
		});
	}

	function renderUntilComplete(app:AppContext, visitor:RouteVisitor):Task<Array<HtmlAsset>> {
		var paths = visitor.drain();
		return Task
			.parallel(...paths.map(path -> renderPath(path, app, visitor)))
			.next(documents -> {
				if (visitor.hasPending()) {
					return renderUntilComplete(app, visitor)
						.next(moreDocuments -> documents.concat(moreDocuments));
				}
				return documents;
			});
	}

	function renderPath(path:String, app:AppContext, visitor:RouteVisitor):Task<HtmlAsset> {
		return new Task(activate -> {
			var document = new ElementPrimitive('#document', {});
			var root:Null<View> = null;
			var suspended = false;
			var activated = false;

			function checkActivation() {
				if (activated) throw 'Activated more than once on a render';
				activated = true;
			}

			function sendHtml(path:String, document:ElementPrimitive) {
				var head = document.children.find(el -> el.as(ElementPrimitive)?.tag == 'head')?.toString({includeTextMarkers: false}) ?? '<head></head>';
				var body = document.children.find(el -> el.as(ElementPrimitive)?.tag == 'body')?.toString({includeTextMarkers: true}) ?? '<body></body>';
				var html = new HtmlAsset(path, '<!doctype html><html>${head}${body}</html>');

				root?.dispose();
				activate(Ok(html));
			}

			root = mount(document, () -> Provider
				.provide(() -> app)
				.provide(() -> visitor)
				.provide(() -> new Navigator({url: path}))
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

	inline function createAppContext() {
		var paths = config.paths;
		return new AppContext(config, fs.directory(paths.privateDirectory), fs.directory(paths.publicDirectory));
	}
}
