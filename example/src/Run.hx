import blok.bridge.log.DefaultLogger;
import blok.bridge.*;
import blok.bridge.plugin.*;

function main() {
	var generator = new Generator({
		render: () -> blog.Blog.node({}),
		children: [
			new Assets({
				assets: [
					CssAsset('/assets/styles.css')
				]
			}),
			new StaticHtml({
				strategy: DirectoryWithIndexHtmlFile
			}),
			new ClientApp({
				dependencies: UseHxml('example-client.hxml'),
				minify: true
			})
		]
	});

	Bridge
		.start({
			version: '0.0.1',
			outputPath: 'dist/www'
		})
		.use(new Logging({
			logger: new DefaultLogger(),
			children: [generator]
		}))
		.run()
		.handle(result -> switch result {
			case Ok(_): trace('Done!');
			case Error(error): trace(error.message);
		});
}
