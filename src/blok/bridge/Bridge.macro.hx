package blok.bridge;

import haxe.macro.Expr;
import blok.bridge.macro.IslandIntrospector;

class Bridge {
	#if blok.client
	public static function hydrateIslands(?options) {
		if (options == null) options = macro null;

		var islands = loadManifest();
		var islandHydration:Array<Expr> = islands.map(islandPath -> {
			var path = islandPath.split('.');
			macro $p{path}.hydrateIslands(adaptor, ${options});
		});
		return macro {
			var adaptor = new blok.html.client.ClientAdaptor();
			var disposables = [$a{islandHydration}];
			blok.core.DisposableItem.ofCallback(() -> {
				for (disposable in disposables) disposable.dispose();
			});
		};
	}
	#else
	public static function trackIslands() {
		registerIslandTracker();
		return macro null;
	}
	#end
}
