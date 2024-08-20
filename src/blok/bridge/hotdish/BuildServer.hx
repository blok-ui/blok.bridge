package blok.bridge.hotdish;

import blok.bridge.Constants;
import hotdish.Node;
import hotdish.node.Build;
import hotdish.node.*;

using haxe.io.Path;
using haxe.Json;

class BuildServer extends Node {
	@:prop public final main:String = 'BridgeGenerate';
	@:prop public final sources:Array<String> = [];
	@:prop public final dependencies:Array<Dependency> = [];
	@:prop public final flags:BuildFlags = new BuildFlags();
	@:prop public final children:Array<Node> = [new Run({})];

	public function build():Array<Node> {
		return [
			new Build({
				main: main,
				sources: sources.concat([DotBridge]),
				dependencies: dependencies,
				flags: flags,
				macros: [
					'blok.bridge.macro.IslandIntrospector.run()'
				],
				children: children
			})
		];
	}
}
