package blog.post;

import blog.layout.MainLayout;
import blog.data.*;

class PostPage extends Component {
	@:attribute final id:String;
	@:resource final post:Post = PostStore.from(this).get(id);

	function render():Child {
		return MainLayout.node({
			pageTitle: 'Post ${post().title}',
			children: post().body.unwrap()
		});
	}
}
