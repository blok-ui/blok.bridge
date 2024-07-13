package blog.post;

import blog.data.*;
import blog.layout.MainLayout;

class ArchivePage extends Component {
	@:resource final posts:Array<Post> = PostStore.from(this).all();

	function render():Child {
		return MainLayout.node({
			pageTitle: 'Archive',
			children: Html.ul().child([for (post in posts())
				Html.li().child(blog.route.Post.link({id: post.slug}).child(post.title))
			])
		});
	}
}
