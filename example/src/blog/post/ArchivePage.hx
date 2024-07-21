package blog.post;

import blog.data.*;
import blog.layout.MainLayout;
import blog.route.PostRoute;

class ArchivePage extends Component {
	@:resource final posts:Array<Post> = PostStore.from(this).all();

	function render():Child {
		return MainLayout.node({
			pageTitle: 'Archive',
			children: Html.ul().child([for (post in posts())
				Html.li().child(PostRoute.link({id: post.slug}).child(post.title))
			])
		});
	}
}
