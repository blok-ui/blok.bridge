package blok.bridge.hotdish;

import hotdish.node.Output;
import hotdish.Node;

class ClientOutput extends Node {
	@:prop final children:Array<Node> = [];

	public function build():Array<Node> {
		var config = BlokBridge.from(this).config;
		return [
			new Output({
				type: Js,
				output: config.paths.createAssetOutputPath(config.getClientAppName()),
				children: children
			})
		];
	}
}
