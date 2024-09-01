package blok.bridge;

import haxe.macro.Expr;
import blok.bridge.macro.IslandIntrospector;

class Bridge {
	#if blok.client
	public static function hydrateIslands() {
		var islands = loadManifest();
		var islandHydration:Array<Expr> = islands.map(islandPath -> {
			var path = islandPath.split('.');
			macro $p{path}.hydrateIslands(adaptor);
		});
		return macro {
			var adaptor = new blok.html.client.ClientAdaptor();
			$b{islandHydration};
		};
	}
	#else
	public static function trackIslands() {
		registerIslandTracker();
		return macro null;
	}
	#end
}
