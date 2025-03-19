package blok.bridge.server;

import blok.bridge.RequestContext;
import blok.bridge.component.DefaultErrorView;
import blok.html.Server;
import blok.html.server.*;
import blok.router.*;
import blok.router.navigation.*;

using blok.Modifiers;

class Generator implements Disposable {
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

		return new Task<NodePrimitive>(activate -> {
			var document = new ElementPrimitive('#document', {});
			var activated = false;
			var node = providers
				.provide()
				.share(context)
				.provide(new AssetContext())
				.provide(new Navigator(new ServerHistory(path), new UrlPathResolver()))
				.provide(new SuspenseBoundaryContext({
					onSuspended: () -> {
						logger.log(Debug, 'Suspended...'); // Or something
					},
					onComplete: () -> {
						if (activated) {
							logger.log(Warning, 'Activated more than once on a render: $path');
							return;
						}

						logger.log(Info, 'Completed rendering [$path]');
						activated = true;
						activate(Ok(document));
					}
				}))
				.child(render())
				.node()
				.inErrorBoundary((component, e) -> {
					if (!activated) {
						activated = true;
						logger.log(Error, e.message);
						activate(Error(new Error(InternalError, e.message)));
					} else {
						logger.log(Error, 'A component failed but triggered onComplete');
						logger.log(Error, e.message);
					}

					context.response.code = InternalServerError;

					return DefaultErrorView.node({
						code: InternalError,
						message: e.message
					});
				});
			var root = mount(document, node);
			owner.addDisposable(root);
		});
	}

	public function dispose() {
		owner.dispose();
	}
}
