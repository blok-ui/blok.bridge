package blok.bridge;

using haxe.io.Path;

// @todo: clean this up and see if we can just merge it with GeneratorConfig.
// Also we might not need most of the options here.
class PathsConfig implements Config {
	@:prop public final dataDirectory:String = 'data'; // @todo: I don't think we use this ever.
	@:prop public final privateDirectory:String = 'dist';
	@:prop public final publicDirectory:String = 'dist/public';
	@:prop public final assetsPath:String = 'assets';

	public function createAssetPath(path:String) {
		return Path.join(['/', assetsPath, path]);
	}

	public function createPrivateOutputPath(path:String) {
		return Path.join([privateDirectory, path]);
	}

	public function createPublicOutputPath(path:String) {
		return Path.join([publicDirectory, path]);
	}

	public function createAssetOutputPath(path:String) {
		return Path.join([publicDirectory, assetsPath, path]);
	}
}
