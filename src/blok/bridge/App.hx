package blok.bridge;

import hotdish.SemVer;
import kit.file.*;
import blok.debug.Debug;
import blok.context.Context;

using Lambda;

@:fallback(error('No App found'))
class App implements Context implements Config {
	@:auto public final version:SemVer;
	@:auto public final fs:FileSystem;
	@:auto public final output:Directory;
	@:auto public final paths:Paths;
}
