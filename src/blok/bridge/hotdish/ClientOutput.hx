package blok.bridge.hotdish;

import hotdish.node.*;
import hotdish.Node;

class ClientOutput extends Node {
	@:prop final children:Array<Node> = [];

	public function build():Array<Node> {
		var bridge = BuildBridge.from(this);
		return [
			new Build({
				flags: {
					'js-es': '6'
				},
				children: [
					new Output({
						type: Js,
						output: bridge.getClientAppOutputPath(),
						children: children
					})
				]
			})
		];
	}
}
