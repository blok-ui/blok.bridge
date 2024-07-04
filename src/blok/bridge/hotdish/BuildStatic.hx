package blok.bridge.hotdish;

import haxe.Template;
import hotdish.Node;
import hotdish.node.Build;
import hotdish.node.*;

using haxe.io.Path;

class BuildStatic extends Node {
	@:prop final main:String = 'BridgeGenerate';
	@:prop final sources:Array<String> = [];
	@:prop final dependencies:Array<Dependency> = [];
	@:prop final flags:BuildFlags = new BuildFlags();
	@:prop final children:Array<Node>;

	public function build():Array<Node> {
		var config = BlokBridge.from(this).config;
		return [
			new Step({
				children: [
					new Artifact({
						path: Path.join([config.generator.artifactPath, main]).withExtension('hx'),
						contents: template.execute({bootstrap: config.generator.bootstrap})
					})
				],
				then: () -> [
					new Build({
						main: main,
						sources: sources.concat([config.generator.artifactPath]),
						dependencies: dependencies,
						flags: flags,
						macros: [
							'blok.bridge.macro.IslandIntrospector.run()'
						],
						children: children
					})
				]
			})
		];
	}
}

private final template = new Template('// THIS IS A GENERATED FILE.
// DO NOT EDIT.

function main() {
	var boot = new ::bootstrap::();
	blok.bridge.Bridge.use(boot);
}
');
