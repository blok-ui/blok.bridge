package blok.bridge;

import blok.suspense.SuspenseBoundaryContext;
import blok.bridge.Events;
import blok.context.Provider;
import blok.html.Server;
import blok.html.server.*;
import blok.router.*;
import blok.suspense.SuspenseBoundary;
import blok.ui.*;

using Lambda;

class Generator {
	final bridge:Bridge;
	final render:() -> Child;

	public function new(bridge, render) {
		this.bridge = bridge;
		this.render = render;
	}

	public function generate():Task<Nothing> {
		bridge.events.init.dispatch();

		var visitor = new RouteVisitor();
		visitor.enqueue('/');

		return renderUntilComplete(visitor)
			.next(_ -> handleOutput())
			.next(cleanup);
	}

	public function generatePage(path:String):Task<Nothing> {
		bridge.events.init.dispatch();

		var visitor = new RouteVisitor();

		return renderPath(path, visitor)
			.next(_ -> handleOutput())
			.next(cleanup);
	}

	function handleOutput() {
		var output = new OutputEvent();

		bridge.events.outputting.dispatch(output);

		return output.run().next(_ -> output.getManifest());
	}

	function cleanup(manifest) {
		var cleanup = new CleanupEvent(manifest);

		bridge.events.cleanup.dispatch(cleanup);

		return cleanup.run().next(_ -> {
			cleanup.dispose();
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
			// var suspended = false;
			var activated = false;

			// @todo: Maybe include a time stamp for when the visit starts and
			// a timestamp for when it ends on the renderComplete event?
			bridge.events.visited.dispatch(path);

			function finish(document:ElementPrimitive) {
				if (activated) throw 'Activated more than once on a render';
				activated = true;
				bridge.events.renderComplete.dispatch(new RenderCompleteEvent(path, document));
				activate(Ok(Nothing));
			}

			var rendered = new RenderEvent(path, render());
			bridge.events.rendering.dispatch(rendered);

			var root = mount(document, () -> Provider
				.provide(() -> visitor)
				.provide(() -> new BridgeContext({bridge: bridge}))
				.provide(() -> new Navigator({
					url: path
				}))
				.provide(() -> new SuspenseBoundaryContext({
					onSuspended: () -> {
						bridge.events.renderSuspended.dispatch(path, document);
					},
					onComplete: () -> {
						if (activated) throw 'Activated more than once on a render';
						activated = true;
						bridge.events.renderComplete.dispatch(new RenderCompleteEvent(path, document));
						activate(Ok(Nothing));
					}
				}))
				.child(_ -> SuspenseBoundary.node({
					child: rendered.unwrap(),
					fallback: () -> Placeholder.node()
				}))
			);

			bridge.events.cleanup.add(disposables -> disposables.addDisposable(root));
		});
	}
}
