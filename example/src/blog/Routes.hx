package blog;

import blog.layout.MainLayout;
import blog.route.*;
import blok.bridge.Bootstrap;
import blok.router.Router;

class Routes extends Bootstrap {
	public function start():Child {
		return Router.node({
			routes: [
				new Home(_ -> MainLayout.node({
					pageTitle: 'Home',
					children: 'Home page'
				})),
				new Archive(params -> MainLayout.node({
					pageTitle: 'Archives | ${params.page}',
					children: 'Archive page ${params.page}'
				})),
				new Counter(params -> MainLayout.node({
					pageTitle: 'Counter | ${params.initial}',
					children: blog.island.Counter.node({count: params.initial})
				}))
			],
			// @todo: we need a real 404 page, as we'll have to output that to the server.
			fallback: _ -> 'Not found'
		});
	}
}
