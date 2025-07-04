import blog.*;
import blok.bridge.*;
import blok.bridge.module.*;

function main() {
	var app = new App<BlogModule, ClientAppModule, #if debug DevServerModule #else StaticSiteGeneratorModule #end>({
		clientDependencies: UseHxml('example-client.hxml'),
		clientMinified: true
	}, () -> blog.Blog.node({}));

	app.run();
}
