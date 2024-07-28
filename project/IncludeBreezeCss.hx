import blok.bridge.*;
import blok.bridge.hotdish.*;
import hotdish.*;
import hotdish.node.*;

// This is a simple custom node to show how you might hook your own build steps
// into Hotdish. In this case, we're adding a node to handle Breeze output.
class IncludeBreezeCss extends Node {
	@:prop final children:Array<Node>;

	function build():Array<Node> {
		return [
			new Build({
				dependencies: [
					{name: 'breeze'},
				],
				flags: {
					// Only output CSS when we're building the static app! We can check which build mode we're
					// in by seeing if there is a parent BuildStatic node.
					'breeze.output': BuildStatic.maybeFrom(this).map(_ -> {
						var config = BlokBridge.from(this).config;
						var path = config.paths.createAssetOutputPath(config.applyVersionToFileName('styles.css'));
						'cwd:$path';
					}).or('none')
				},
				children: children
			})
		];
	}
}
