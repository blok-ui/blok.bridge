package blok.bridge;

import haxe.macro.Expr;

using Reflect;
using haxe.io.Path;

class BridgeProject {
	public static function embed():Expr {
		return blok.bridge.macro.ProjectEmbedder.embed(macro blok.bridge.BridgeProject.fromJson);
	}
}
