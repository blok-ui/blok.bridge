package blog;

import blog.data.PostStore;
import blok.bridge.*;
import capsule.*;
import kit.file.*;

// @todo: Probably don't want to make the end-user forced to deal with something like this
// unless they want to. This is very clunky, we can come up with a better solution.
class BlogModule implements Module {
	public function new() {}

	public function provide(container:Container) {
		container.map(PostStore).to((fs:FileSystem) -> new PostStore(fs.directory('example/data/post')));

		container.when(AppProviders).resolved((store:PostStore) -> value.add(store));

		#if debug
		container.map(kit.http.Server).to(new kit.http.server.NodeServer(8080)).share();
		#end
	}
}
