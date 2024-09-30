package blok.bridge;

import blok.core.Scheduler;
import blok.bridge.Events;
import blok.context.Provider;
import blok.core.BlokException;
import blok.debug.Debug.warn;
import blok.html.Server;
import blok.html.server.*;
import blok.router.*;
import blok.suspense.SuspenseBoundaryContext;
import blok.ui.*;

using Lambda;
using blok.boundary.BoundaryModifiers;
using blok.suspense.SuspenseModifiers;

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
		var cleanupEvent = new CleanupEvent(manifest);

		bridge.events.cleanup.dispatch(cleanupEvent);

		return cleanupEvent.run().next(_ -> {
			cleanupEvent.dispose();
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
			var activated = false;

			bridge.events.visited.dispatch(path);

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
						if (activated) {
							warn('Activated more than once on a render: $path');
							return;
						}
						activated = true;
						bridge.events.renderComplete.dispatch(new RenderCompleteEvent(path, document));
						activate(Ok(Nothing));
					}
				}))
				.child(_ -> rendered
					.unwrap()
					.inSuspense(() -> Placeholder.node())
					.node()
				)
				.node()
				.inErrorBoundary((component, e) -> {
					if (e is BlokException) {
						bridge.events.renderFailed.dispatch(cast e);
					} else {
						bridge.events.renderFailed.dispatch(new BlokComponentException(e.message, component));
					}

					if (!activated) {
						activated = true;
						activate(Error(new Error(InternalError, e.message)));
					} else {
						warn('A component failed but activated anyway');
					}

					Placeholder.node(); // @todo: An actual failure view?
				})
			);

			bridge.events.cleanup.add(disposables -> disposables.addDisposable(root));
		});
	}
}
