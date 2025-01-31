package blok.bridge.plugin;

import blok.BlokException;
import blok.bridge.component.DefaultErrorView;
import blok.debug.Debug;
import blok.html.Server;
import blok.html.server.*;
import blok.router.*;
import blok.router.RouteVisitor;
import blok.router.navigation.*;
import haxe.Exception;
import kit.Error;

using Lambda;
using blok.Modifiers;

enum RenderMode {
	RenderFullSiteWithErrorPage;
	RenderFullSite(?include:Array<Path>);
	RenderSinglePage(page:Path);
}

class Generate extends Plugin {
	@:noUsing
	public static function from(plugin:Plugin) {
		return maybeFrom(plugin).orThrow('No Render plugin found');
	}

	@:noUsing
	public static function maybeFrom(plugin:Plugin) {
		return plugin.findAncestorOfType(Generate);
	}

	public final rendering = new Event<Path, NodePrimitive, RenderResult>();
	public final renderComplete = new Event<Path, NodePrimitive>();
	public final renderSuspended = new Event<Path, NodePrimitive>();
	public final renderFailed = new Event<Exception>();

	@:value final mode:RenderMode;
	@:value final render:() -> Child;
	@:value final error:(code:ErrorCode, message:String) -> Child = (code, message) -> DefaultErrorView.node({
		code: code,
		message: message
	});
	@:value final children:Array<Plugin>;

	// public function include(path:String) {
	// }

	public function run() {
		for (child in children) registerChild(child);

		var link = Core.from(this).generate.add(queue -> {
			var visitor = new RouteVisitor();

			switch mode {
				case RenderFullSiteWithErrorPage:
					visitor.enqueue('/');
					visitor.enqueue('/404.html');
					queue.enqueue(renderUntilComplete(visitor));
				case RenderFullSite(include):
					visitor.enqueue('/');
					if (include != null) for (path in include) visitor.enqueue(path);
					queue.enqueue(renderUntilComplete(visitor));
				case RenderSinglePage(path):
					visitor.enqueue(path);
					queue.enqueue(renderPath(path, visitor));
			}
		});

		addDisposable(() -> link.cancel());
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
		Logging.maybeFrom(this).inspect(logger -> logger.log(Info, 'Rendering $path'));

		return new Task(activate -> {
			var document = new ElementPrimitive('#document', {});
			var activated = false;
			var rendered = new RenderResult(render());

			rendering.dispatch(path, document, rendered);

			var root = mount(document, Provider
				.share(visitor)
				.share(Core.from(this).bridge)
				.provide(new Navigator(new ServerHistory(path), new UrlPathResolver()))
				.provide(new SuspenseBoundaryContext({
					onSuspended: () -> {
						renderSuspended.dispatch(path, document);
					},
					onComplete: () -> {
						if (activated) {
							warn('Activated more than once on a render: $path');
							return;
						}
						activated = true;
						renderComplete.dispatch(path, document);
						activate(Ok(Nothing));
					}
				}))
				.child(rendered
					.unwrap()
					.inSuspense(() -> Placeholder.node())
					.node()
				)
				.node()
				.inErrorBoundary((component, e) -> {
					if (e is BlokException) {
						renderFailed.dispatch(cast e);
					} else {
						renderFailed.dispatch(new BlokComponentException(e.message, component));
					}

					if (!activated) {
						activated = true;
						activate(Error(new Error(InternalError, e.message)));
					} else {
						warn('A component failed but triggered onComplete');
					}

					return error(InternalError, e.message);
				})
			);

			addDisposable(root);
		});
	}
}

typedef Path = String;

class RenderResult {
	var child:Child;

	public function new(child) {
		this.child = child;
	}

	public function apply(render:(child:Child) -> Child) {
		this.child = render(this.child);
	}

	public function unwrap() {
		return child;
	}
}
