package blok.bridge.hotdish;

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
	@:prop final children:Array<Node> = [new ClientOutput({})];

	public function build():Array<Node> {
		var config = BlokBridge.from(this).config;
		return [
			new Step({
				children: [
					new Artifact({
						path: Path.join([config.generator.artifactPath, main]).withExtension('hx'),
						contents: contents
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
						children: children
					})
				]
			})
		];
	}
}

private final contents = '// THIS IS A GENERATED FILE.
// DO NOT EDIT.

function main() {
	#if blok.client
	blok.bridge.Bridge.startIslands();
	#end
}
';
