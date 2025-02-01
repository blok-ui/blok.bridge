import blok.bridge.*;
import blok.bridge.plugin.*;

// import blok.bridge.CoreExtensions;
function main() {
	// Bridge
	// 	.start({
	// 		version: '0.0.1',
	// 		outputPath: 'dist/www'
	// 	})
	// 	.use(
	// 		linkAssets([
	// 			CssAsset('/assets/styles.css')
	// 		]),
	// 		generateStaticHtml(DirectoryWithIndexHtmlFile),
	// 		generateClientApp({
	// 			dependencies: UseHxml('example-client.hxml')
	// 		}),
	// 		visitNotFoundPage(),
	// 		useLogging(),
	// 		outputHtAccess(),
	// 		outputRobotsTxt(),
	// 		cleanupUnusedFiles()
	// 	)
	// 	.generate(() -> blog.Blog.node({}))
	// 	.handle(result -> switch result {
	// 		case Ok(_): trace('Done!');
	// 		case Error(error): trace(error.message);
	// 	});

	Bridge
		.start({
			version: '0.0.1',
			outputPath: 'dist/www'
		})
		.use(
			new Generator({
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
			}),
		)
		.run()
		.handle(result -> switch result {
			case Ok(_): trace('Done!');
			case Error(error): trace(error.message);
		});
}
