package blok.bridge.hotdish;

import hotdish.Node;
import hotdish.node.Build;

class BuildStatic extends Node {
	@:prop final sources:Array<String> = [];
	@:prop final dependencies:Array<Dependency> = [];
	@:prop final flags:BuildFlags = new BuildFlags();
	@:prop final children:Array<Node>;

	public function build():Array<Node> {
		return [
			new Build({
				sources: sources,
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
