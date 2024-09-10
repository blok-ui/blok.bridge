import blok.bridge.*;
import blok.bridge.plugin.*;

function main() {
	Bridge.start({
		version: '0.0.1',
		outputPath: 'dist/www'
	})
		.plugins([
			new StaticHtml({
				strategy: DirectoryWithIndexHtmlFile
			}),
			new ClientApp({
				dependencies: UseHxml('example-client.hxml')
			}),
			new LinkedAssets([
				CssAsset('/assets/styles.css', true)
			]),
			new RemoveUnusedFiles()
		])
		.generate(() -> blog.Blog.node({}))
		.handle(result -> switch result {
			case Ok(_): trace('Done!');
			case Error(error): trace(error.message);
		});
}
