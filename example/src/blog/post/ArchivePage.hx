package blog.post;

import blog.data.*;
import blog.layout.MainLayout;
import blog.route.PostRoute;

class ArchivePage extends Component {
	@:context final store:PostStore;
	@:resource final posts:Array<Post> = store.all();

	function render():Child {
		return MainLayout.node({
			pageTitle: 'Archive',
			children: Html.ul().child([for (post in posts())
				Html.li().child(PostRoute.link({id: post.slug}).child(post.title))
			])
		});
	}
}
