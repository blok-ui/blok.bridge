import blok.bridge.*;

function main() {
	Bridge
		.start({
			version: '0.0.1',
			clientDependencies: UseHxml('example-client.hxml'),
			target: Server(8080)
		})
		.run(() -> blog.Blog.node({}));
}
