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
				flags: ['-D breeze.output=none'],
				dependencies: InheritDependencies
				// sources: ['example/src'],
				// dependencies: UseCustom([
				// 	{name: 'breeze'},
				// 	{name: 'blok.foundation'}
				// ])
			}),
			new LinkedAssets([
				CssAsset('dist/www/assets/styles.css', true)
			])
				// new BreezeCss({})
		])
		.generate(() -> blog.Blog.node({}))
		.handle(result -> switch result {
			case Ok(_): trace('Done!');
			case Error(error): trace(error.message);
		});
}
