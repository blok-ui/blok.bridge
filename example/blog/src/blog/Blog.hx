package blog;

import blog.island.IslandWIthContext;
import blog.context.BlogConfig;
import blog.layout.MainLayout;
import blog.post.*;
import blog.route.*;
import blog.ui.*;
import blok.bridge.component.DefaultNotFoundRoute;
import blok.router.Router;

class Blog extends Component {
	public function render():Child {
		return Provider
			.provide(new BlogConfig({name: 'Test Blog'}))
			.child(Router.node({
				routes: [
					HomeRoute.route(_ -> {
						MainLayout.node({
							pageTitle: 'Home',
							children: [
								Collapse.node({
									header: 'Home',
									children: [
										Heading.node({children: 'Hey world!'}),
										Html.p().child('This is the home page!'),
										Html.p().child('It can be collapsed.')
									]
								}),
								IslandWIthContext.node({})
							]
						});
					}),
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
