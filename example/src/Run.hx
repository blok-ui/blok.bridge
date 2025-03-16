import blok.bridge.*;

function main() {
	Bridge
		.start({
			version: '0.0.1',
			clientDependencies: UseHxml('example-client.hxml'),
			clientMinified: true,
			#if debug
			target: Server(8080),
			#else
			target: Static(DirectoryWithIndexHtmlFile),
			#end
		})
		.run(() -> blog.Blog.node({}));
}
