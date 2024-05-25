package blok.bridge.hotdish;

import hotdish.Node;
import hotdish.node.*;
import hotdish.node.Build;

using StringTools;
using haxe.io.Path;

class BuildClient extends Node {
	// @:prop final main:String = 'BridgeIslands';
	@:prop final sources:Array<String> = [];
	@:prop final dependencies:Array<Dependency> = [];
	@:prop final flags:BuildFlags = new BuildFlags();

	public function build():Array<Node> {
		var config = BlokBridge.from(this).config;
		return [
			new Build({
				sources: sources,
				dependencies: dependencies,
				flags: flags.merge(BuildFlags.fromMap([
					'blok.client' => true
				])),
				children: [
					new Output({
						type: Js,
						output: config.paths.createAssetOutputPath(config.getClientAppName())
					})
				]
			})
		];
	}
}
