package blog;

import blog.data.PostStore;
import blog.layout.MainLayout;
import blog.post.*;
import blog.route.*;
import blog.ui.*;
import blok.bridge.BridgeContext;
import blok.bridge.component.DefaultNotFoundRoute;
import blok.context.Provider;
import blok.router.Router;

class Blog extends Component {
	@:context final bridge:BridgeContext;

	public function render():Child {
		return Provider
			.provide(new PostStore(bridge.fs.directory('example/data/post')))
			.child(Router.node({
				routes: [
					HomeRoute.route(_ -> MainLayout.node({
						pageTitle: 'Home',
						children: [
							Collapse.node({
								header: 'Home',
								children: [
									Heading.node({children: 'Hey world!'}),
									Html.p().child('This is the home page!'),
									Html.p().child('It can be collapsed.')
								]
							})
						]
					})),
					CounterRoute.route(params -> MainLayout.node({
						pageTitle: 'Counter | ${params.initial}',
						children: blog.island.Counter.node({count: params.initial})
					})),
					ArchiveRoute.route(params -> ArchivePage.node({})),
					PostRoute.route({}),
					DelayRoute.route({}),
					DefaultNotFoundRoute.route({})
				]
			}));
	}
}
