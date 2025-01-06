package blok.bridge.component;

import blok.*;
import blok.router.Page;

class DefaultNotFoundRoute extends Page<'*'> {
	function render():Child {
		return DefaultErrorView.node({
			code: NotFound,
			message: 'Page not found'
		});
	}
}
