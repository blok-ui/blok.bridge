package blok.bridge;

import blok.data.Structure;

using haxe.io.Path;

// @todo: Clean this up some more...
// Honestly, we might not really need this?
class Paths extends Structure {
	@:constant public final assetPrefix:String = 'assets';
	@:constant public final clientApp:String = 'assets/app.js';

	public function formatAssetPath(path:String) {
		return Path.join(['/', assetPrefix, path]);
	}
}
