import blok.bridge.*;
import blok.bridge.plugin.*;

function main() {
	Bridge.start({
		version: '0.0.1',
		outputPath: 'dist/www'
	})
		.plugins([
			new LinkAssets([
				CssAsset('/assets/styles.css', true)
			]),
			new GenerateStaticHtml({
				strategy: DirectoryWithIndexHtmlFile
			}),
			new GenerateClientApp({
				dependencies: UseHxml('example-client.hxml')
			}),
			new RemoveUnusedFiles(),
			new UseLogging()
		])
		.generate(() -> blog.Blog.node({}))
		.handle(result -> switch result {
			case Ok(_): trace('Done!');
			case Error(error): trace(error.message);
		});
}
