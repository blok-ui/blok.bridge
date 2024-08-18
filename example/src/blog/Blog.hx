package blog;

import blog.data.PostStore;
import blog.layout.MainLayout;
import blog.post.*;
import blog.route.*;
import blog.ui.*;
import blok.bridge.App;
import blok.context.Provider;
import blok.router.Router;

class Blog extends Component {
	@:context final app:App;

	public function render():Child {
		return Provider
			.provide(() -> new PostStore(app.fs.directory('example/data/post')))
			.child(_ -> Router.node({
				routes: [
					new HomeRoute(_ -> MainLayout.node({
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
					new CounterRoute(params -> MainLayout.node({
						pageTitle: 'Counter | ${params.initial}',
						children: blog.island.Counter.node({count: params.initial})
					})),
					new ArchiveRoute(params -> ArchivePage.node({})),
					new PostRoute({})
				],
				// @todo: we need a real 404 page, as we'll have to output that to the server.
				fallback: _ -> 'Not found'
			}));
	}
}
