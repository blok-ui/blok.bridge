package blok.bridge.hotdish;

import haxe.Template;
import hotdish.Node;
import hotdish.node.*;
import hotdish.node.Build;

using StringTools;
using haxe.io.Path;

class BuildClient extends Node {
	@:prop final main:String = 'BridgeIslands';
	@:prop final sources:Array<String> = [];
	@:prop final dependencies:Array<Dependency> = [];
	@:prop final flags:BuildFlags = new BuildFlags();

	public function build():Array<Node> {
		var config = BlokBridge.from(this).config;
		return [
			new Step({
				children: [
					new Artifact({
						path: Path.join([config.generator.artifactPath, main]).withExtension('hx'),
						contents: template.execute({})
					})
				],
				then: () -> [
					new Build({
						sources: sources.concat([config.generator.artifactPath]),
						main: main,
						dependencies: dependencies,
						flags: flags.merge({
							'blok.client': true
						}),
						children: [
							new Output({
								type: Js,
								output: config.paths.createAssetOutputPath(config.getClientAppName())
							})
						]
					})
				]
			})
		];
	}
}

private final template = new Template('// THIS IS A GENERATED FILE.
// DO NOT EDIT.

function main() {
	#if blok.client
	blok.bridge.Bridge.startIslands();
	#end
}
');
