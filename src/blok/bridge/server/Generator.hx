package blok.bridge.server;

import blok.bridge.RequestContext;
import blok.bridge.component.*;
import blok.core.*;
import blok.html.server.*;
import blok.router.*;
import blok.router.navigation.*;

using blok.Modifiers;

class Generator implements Disposable {
	public final onPageVisited = new Event<String>();
	public final onPageRendered = new Event<String, NodePrimitive>();

	final render:Render;
	final logger:Logger;
	final providers:AppProviders;
	final owner = new Owner();

	public function new(render, logger, providers) {
		this.render = render;
		this.logger = logger;
		this.providers = providers;
	}

	public function generatePage(context:RequestContext):Task<NodePrimitive> {
		var path = context.request.url.toString();

		logger.log(Info, 'Rendering [$path]');
		onPageVisited.dispatch(path);

		return new Task<NodePrimitive>(activate -> {
			var document = new ElementPrimitive('#document', {});
			var activated = false;
			var node = providers
				.provide()
				.share(context)
				.provide(new HeadContext())
				.provide(new Navigator(new ServerHistory(path), new UrlPathResolver()))
				.provide(new SuspenseBoundaryContext({
					onSuspended: () -> {
						logger.log(Info, 'Suspending [$path]...');
					},
					onComplete: () -> {
						if (activated) {
							logger.log(Warning, 'Activated more than once on a render: $path');
							return;
						}

						logger.log(Info, 'Completed rendering [$path]');

						onPageRendered.dispatch(path, document);

						activated = true;
						activate(Ok(document));
					}
				}))
				.child(Scope.wrap(_ -> render()).inSuspense(() -> DefaultSuspenseView.node({})))
				.node()
				.inErrorBoundary((e) -> {
					var error:Error = e;
					logger.log(Error, error.toString());
					context.response.code = error.code;
					return DefaultErrorView.node({error: error});
				});

			var root = new Root(document, new ServerAdaptor(), node);

			root.mount()
				.inspect(_ -> owner.addDisposable(root))
				.orThrow();
		});
	}

	public function dispose() {
		owner.dispose();
	}
}
