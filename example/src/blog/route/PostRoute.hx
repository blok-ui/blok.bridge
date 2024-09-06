package blog.route;

import blok.router.*;
import blog.layout.MainLayout;
import blog.data.*;

class PostRoute extends PageRoute<'/post/{id:String}'> {
	@:context final store:PostStore;
	@:resource final post:Post = store.get(id());

	public function render():Child {
		return MainLayout.node({
			pageTitle: 'Post ${post().title}',
			children: post().body
		});
	}
}
