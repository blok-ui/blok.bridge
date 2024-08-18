package blok.bridge;

using haxe.io.Path;

// @todo: Clean this up some more...
// Honestly, we might not really need this?
class Paths implements Config {
	@:auto public final assetPrefix:String = 'assets';
	@:auto public final clientApp:String = 'assets/app.js';

	public function formatAssetPath(path:String) {
		return Path.join(['/', assetPrefix, path]);
	}
}
