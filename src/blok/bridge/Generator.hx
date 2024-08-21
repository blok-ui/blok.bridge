package blok.bridge;

import blok.context.Provider;
import blok.html.Server;
import blok.html.server.*;
import blok.router.*;
import blok.suspense.SuspenseBoundary;
import blok.ui.*;

using Lambda;

class Generator {
	final app:App;
	final render:() -> Child;
	final plugins:Array<Plugin>;

	public function new(app, render, plugins) {
		this.app = app;
		this.render = render;
		this.plugins = plugins;
	}

	public function generate():Task<Nothing> {
		var visitor = new RouteVisitor();

		visitor.enqueue('/');

		return renderUntilComplete(visitor)
			.next(_ -> Task.parallel(...plugins.map(plugin -> plugin.handleOutput(app))));
	}

	public function generatePage(path:String):Task<Nothing> {
		var visitor = new RouteVisitor();
		return renderPath(path, visitor).next(_ -> plugins.map(plugin -> plugin.handleOutput(app)));
	}

	function renderUntilComplete(visitor:RouteVisitor):Task<Nothing> {
		var paths = visitor.drain();
		return Task
			.parallel(...paths.map(path -> renderPath(path, visitor)))
			.next(_ -> {
				if (visitor.hasPending()) {
					return renderUntilComplete(visitor);
				}
				return Task.nothing();
			});
	}

	function renderPath(path:String, visitor:RouteVisitor):Task<Nothing> {
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
				for (plugin in plugins) plugin.handleGeneratedPath(app, path, document);

				root?.dispose();

				activate(Ok(Nothing));
			}

			root = mount(document, () -> Provider
				.provide(() -> visitor)
				.provide(() -> app)
				.provide(() -> new Navigator({
					url: path
				}))
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
