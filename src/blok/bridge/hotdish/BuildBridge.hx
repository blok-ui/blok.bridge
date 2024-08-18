package blok.bridge.hotdish;

import haxe.io.Path;
import blok.bridge.generate.HtmlGenerationStrategy;
import hotdish.node.*;
import hotdish.*;

class BuildBridge extends Node {
	@:prop public final bootstrap:String = 'Boot';
	@:prop public final version:SemVer = '0.0.1';
	@:prop public final outputDirectory:String = 'dist/www';
	@:prop public final assetPrefix:String = 'assets';
	@:prop public final strategy:HtmlGenerationStrategy = DirectoryWithIndexHtmlFile;

	@:prop final server:BuildStatic;
	@:prop final client:BuildClient = new BuildClient({});

	// @todo: merge this with Paths?
	public function formatOutputPath(path:String) {
		return Path.join([outputDirectory, path]);
	}

	public function formatAssetPath(path:String) {
		return Path.join(['/', assetPrefix, path]);
	}

	public function formatAssetOutputPath(path:String) {
		return formatOutputPath(formatAssetPath(path));
	}

	public function getClientAppName() {
		return 'app_' + version.toFileNameSafeString() + '.js';
	}

	public function getClientAppPath() {
		return formatAssetPath(getClientAppName());
	}

	public function getClientAppOutputPath() {
		return formatAssetOutputPath(getClientAppName());
	}

	public function build():Array<Node> return [
		new Build({
			dependencies: [
				{name: 'blok.bridge'}
			],
			// flags: {
			// 	'blok.bridge.version': version.toString(),
			// 	'blok.bridge.output': outputDirectory,
			// 	'blok.bridge.strategy': strategy,
			// 	'blok.bridge.asset-prefix': assetPrefix,
			// 	'blok.bridge.client-app': getClientAppName()
			// },
			children: [
				new Step({
					children: [server],
					then: () -> [client]
				})
			]
		})
	];
}
