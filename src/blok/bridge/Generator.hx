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
	final plugins:Plugins;

	public function new(app, render, plugins) {
		this.app = app;
		this.render = render;
		this.plugins = plugins;
	}

	public function generate():Task<Nothing> {
		var visitor = new RouteVisitor();

		visitor.enqueue('/');

		return renderUntilComplete(visitor)
			.next(_ -> plugins.output(app))
			.next(_ -> {
				plugins.cleanup();
				Task.nothing();
			});
	}

	public function generatePage(path:String):Task<Nothing> {
		var visitor = new RouteVisitor();
		return renderPath(path, visitor)
			.next(_ -> plugins.output(app))
			.next(_ -> {
				plugins.cleanup();
				Task.nothing();
			});
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
			var suspended = false;
			var activated = false;

			function finish(document:ElementPrimitive) {
				if (activated) throw 'Activated more than once on a render';
				activated = true;
				plugins.visited(app, path, document);
				activate(Ok(Nothing));
			}

			// @todo: We need to dispose of this thing :/
			// Or, better yet, figure out how to just reuse it
			// and render when our Navigator changes the URL.
			var root = mount(document, () -> Provider
				.provide(() -> visitor)
				.provide(() -> app)
				.provide(() -> new Navigator({
					url: path
				}))
				.child(_ -> SuspenseBoundary.node({
					child: plugins.render(app, render()),
					onSuspended: () -> suspended = true,
					onComplete: () -> finish(document),
					fallback: () -> Placeholder.node()
				}))
			);

			if (suspended == false) finish(document);
		});
	}
}
