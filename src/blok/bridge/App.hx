package blok.bridge;

import hotdish.SemVer;
import kit.file.*;
import blok.data.*;
import blok.debug.Debug;
import blok.context.Context;

using Lambda;

@:fallback(error('No App found'))
class App extends Structure implements Context {
	@:constant public final version:SemVer;
	@:constant public final fs:FileSystem;
	@:constant public final output:Directory;

	public function dispose() {}
}
