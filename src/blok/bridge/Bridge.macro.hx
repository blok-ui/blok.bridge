package blok.bridge;

import haxe.macro.Expr;
import blok.bridge.macro.IslandIntrospector;

class Bridge {
	public static function startIslands() {
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
}
