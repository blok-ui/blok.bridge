package blok.bridge.util;

import haxe.macro.Context;

class Sources {
	static function getCurrentClassPaths() {
		var paths = Context.getClassPath();
		var exprs = [for (path in paths) macro $v{path}];
		return macro [$a{exprs}];
	}
}
