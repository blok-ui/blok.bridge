package blog.route;

import blok.router.*;
import blog.layout.MainLayout;
import blog.data.*;

class PostRoute extends PageRoute<'/post/{id:String}'> {
	@:resource final post:Post = PostStore.from(context()).get(id());

	public function render():Child {
		return MainLayout.node({
			pageTitle: 'Post ${post().title}',
			children: post().body.unwrap()
		});
	}
}
