package spa;

import blok.*;
import blok.bridge.*;
import blok.router.*;
import spa.routes.*;

class AppRouter extends Island {
	@:context final navigator:Navigator;

	function render():Child {
		return Router.node({
			routes: [
				HomePage.route({}),
				EditTask.route({}),
				Route.to('*').renders(_ -> 'Not found')
			]
		});
	}
}
