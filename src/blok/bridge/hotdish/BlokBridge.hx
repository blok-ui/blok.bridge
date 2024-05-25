package blok.bridge.hotdish;

import hotdish.node.Build.BuildFlags;
import hotdish.node.*;
import hotdish.Node;

class BlokBridge extends Node {
	@:prop public final config:AppConfig;

	// @:prop final children:Array<Node>;
	@:prop final server:BuildStatic;
	@:prop final client:BuildClient = new BuildClient({});

	public function build():Array<Node> {
		return [
			new Build({
				dependencies: [
					{name: 'blok.bridge'}
				],
				flags: BuildFlags.fromMap([
					'blok.generator.version' => config.generator.version.toString(),
					'blok.generator.strategy' => config.generator.strategy,
					'blok.generator.manifest' => config.generator.manifestName,
					'blok.generator.artifacts' => config.generator.artifactPath,
					'blok.paths.data' => config.paths.dataDirectory,
					'blok.paths.private' => config.paths.privateDirectory,
					'blok.paths.public' => config.paths.publicDirectory,
					'blok.paths.assets' => config.paths.assetsPath
				]),
				children: [
					new Step({
						children: [server],
						then: () -> [client]
					})
				]
			})
		];
	}
}
