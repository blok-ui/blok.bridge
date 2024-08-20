package blok.bridge.hotdish;

import blok.bridge.Constants;
import hotdish.Node;
import hotdish.node.Build;

using StringTools;
using haxe.io.Path;

class BuildClient extends Node {
	@:prop public final main:String = 'BridgeIslands';
	@:prop public final sources:Array<String> = [];
	@:prop public final dependencies:Array<Dependency> = [];
	@:prop public final flags:BuildFlags = new BuildFlags();
	@:prop public final children:Array<Node> = [new ClientOutput({})];

	public function build():Array<Node> {
		return [
			new Build({
				sources: sources.concat([DotBridge]),
				main: main,
				dependencies: dependencies,
				flags: flags.merge({
					'blok.client': true,
					'js-es': 6
				}),
				children: children
			})
		];
	}
}
