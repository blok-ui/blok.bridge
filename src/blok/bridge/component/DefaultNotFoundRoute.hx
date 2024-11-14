package blok.bridge.component;

import blok.ui.*;
import blok.router.RouteComponent;

class DefaultNotFoundRoute extends RouteComponent<'*'> {
	function render():Child {
		return DefaultErrorView.node({
			code: NotFound,
			message: 'Page not found'
		});
	}
}
