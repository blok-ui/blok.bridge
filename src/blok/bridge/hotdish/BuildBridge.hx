package blok.bridge.hotdish;

import blok.bridge.generate.AssetLink;
import blok.bridge.generate.HtmlGenerationStrategy;
import haxe.io.Path;
import hotdish.*;
import hotdish.node.*;

class BuildBridge extends Node {
	@:prop public final bootstrap:String = 'Boot';
	@:prop public final version:SemVer = '0.0.1';
	@:prop public final outputDirectory:String = 'dist/www';
	@:prop public final assetPrefix:String = 'assets';
	@:prop public final strategy:HtmlGenerationStrategy = DirectoryWithIndexHtmlFile;
	@:prop public final links:Array<AssetLink> = [];

	@:prop final server:BuildServer;
	@:prop final client:BuildClient = new BuildClient({});

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

	public function addLink(link:AssetLink) {
		this.links.push(link);
		return this;
	}

	public function build():Array<Node> return [
		new Build({
			dependencies: [
				{name: 'blok.bridge'}
			],
			children: [
				new Step({
					children: [server],
					then: () -> [client]
				})
			]
		})
	];
}
