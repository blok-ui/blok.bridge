package blog;

import blog.data.PostStore;
import blog.layout.MainLayout;
import blog.post.PostPage;
import blog.route.*;
import blog.ui.*;
import blok.bridge.Bootstrap;
import blok.context.Provider;
import blok.router.Router;
import kit.file.FileSystem;
import kit.file.adaptor.SysAdaptor;

class Routes extends Bootstrap {
	public function start():Child {
		var fs = new FileSystem(new SysAdaptor(Sys.getCwd()));
		return Provider
			.provide(() -> new PostStore(fs.directory('example/data/post')))
			.child(_ -> Router.node({
				routes: [
					new Home(_ -> MainLayout.node({
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
					new Archive(params -> MainLayout.node({
						pageTitle: 'Archives | ${params.page}',
						children: 'Archive page ${params.page}'
					})),
					new Counter(params -> MainLayout.node({
						pageTitle: 'Counter | ${params.initial}',
						children: blog.island.Counter.node({count: params.initial})
					})),
					new Post(params -> PostPage.node({
						id: params.id
					}))
				],
				// @todo: we need a real 404 page, as we'll have to output that to the server.
				fallback: _ -> 'Not found'
			}));
	}
}
