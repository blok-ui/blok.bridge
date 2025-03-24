package spa;

import blok.router.*;
import blok.*;
import blok.bridge.*;

class AppRouter extends Island {
	@:context final navigator:Navigator;

	function render():Child {
		return Router.node({
			routes: []
		});
	}
}
