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
					// in by seeing if there is a parent BuildServer node.
					'breeze.output': BuildServer.maybeFrom(this).map(_ -> {
						var bridge = BuildBridge.from(this);
						var path = 'styles-${bridge.version.toFileNameSafeString()}.css';
						var fullPath = bridge.formatAssetOutputPath(path);

						// Configure bridge to automatically link to the generated
						// css file in our HTML output.
						bridge.addLink(CssLink(bridge.formatAssetPath(path)));

						'cwd:$fullPath';
					}).or('none')
				},
				children: children
			})
		];
	}
}
