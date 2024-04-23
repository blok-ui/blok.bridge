package blok.bridge.asset;

import haxe.macro.Context;

class ClientAppAsset {
	// @todo: Test this without using lix and node
	static function getCurrentClassPaths() {
		var paths = Context.getClassPath();
		var exprs = [for (path in paths) macro $v{path}];
		return macro [$a{exprs}];
	}
}
