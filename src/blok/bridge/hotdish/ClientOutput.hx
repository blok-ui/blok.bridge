package blok.bridge.hotdish;

import blok.bridge.Constants;
import hotdish.Node;
import hotdish.node.*;

using StringTools;
using haxe.io.Path;

class ClientOutput extends Node {
	@:prop final children:Array<Node> = [];

	public function build():Array<Node> {
		var bridge = BuildBridge.from(this);
		var client = BuildClient.from(this);

		return [
			new Step({
				children: [
					new Artifact({
						path: Path.join([DotBridge, client.main]).withExtension('hx'),
						contents: contents
					})
				],
				then: () -> [new Output({
					type: Js,
					output: bridge.getClientAppOutputPath(),
					children: children
				})]
			})
		];
	}
}

private final contents = '// THIS IS A GENERATED FILE.
// DO NOT EDIT.

function main() {
	#if blok.client
	blok.bridge.Bridge.hydrateIslands();
	#end
}
';
