package blog.route;

import blok.router.*;
import blog.layout.MainLayout;
import blog.data.*;

class PostRoute extends Page<'/post/{id:String}'> {
	@:context final store:PostStore;
	@:resource final post:Post = store.get(id());

	public function render():Child {
		// blok.debug.Debug.error('fail');
		return MainLayout.node({
			pageTitle: 'Post ${post().title}',
			children: post().body
		});
	}
}
