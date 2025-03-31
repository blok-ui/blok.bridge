package blok.bridge.component;

import blok.*;
import blok.router.Page;

class DefaultNotFoundRoute extends Page<'*'> {
	function render():Child {
		RequestContext.maybeFrom(this).inspect(context -> {
			context.response.code = NotFound;
		});

		return DefaultErrorView.node({error: new Error(NotFound, 'Page not found')});
	}
}
