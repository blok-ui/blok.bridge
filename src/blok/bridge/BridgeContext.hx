package blok.bridge;

import blok.bridge.util.SemVer;
import blok.context.Context;
import blok.data.Object;
import blok.debug.Debug;
import kit.file.*;

@:fallback(error('No BridgeContext found'))
class BridgeContext extends Object implements Context {
	@:value final bridge:Bridge;

	@:prop(get = bridge.fs) public final fs:FileSystem;
	@:prop(get = bridge.output) public final output:Directory;
	@:prop(get = bridge.version) public final version:SemVer;

	public function unwrap() {
		return bridge;
	}

	public function dispose() {}
}
