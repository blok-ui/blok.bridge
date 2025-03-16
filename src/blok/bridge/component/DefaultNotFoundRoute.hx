package blok.bridge.component;

import blok.*;
import blok.router.Page;

class DefaultNotFoundRoute extends Page<'*'> {
	function render():Child {
		BridgeRequest.maybeFrom(this).inspect(context -> {
			context.response.code = NotFound;
		});

		return DefaultErrorView.node({
			code: NotFound,
			message: 'Page not found'
		});
	}
}
