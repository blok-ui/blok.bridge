package blok.bridge;

#if !blok.client
import blok.bridge.util.*;
import kit.file.*;
import kit.file.adaptor.*;
#end
import blok.data.Object;
import blok.debug.Debug;

@:fallback(error('No Bridge instance found'))
class Bridge extends Object implements Context {
	#if blok.client
	public macro static function hydrateIslands(?options);
	#else
	public macro static function trackIslands();

	public inline static function start(props) {
		trackIslands();
		return new Bridge(props);
	}

	@:value public final fs:FileSystem = new FileSystem(new SysAdaptor(Sys.getCwd()));
	@:value public final outputPath:String = 'dist/www';
	@:value public final version:SemVer;

	public final events:Events;
	public final output:Directory;

	public function new() {
		events = new Events();
		output = fs.directory(outputPath);
	}

	public function use(...extensions:Extension) {
		for (extension in extensions) extension.apply(this);
		return this;
	}

	public function generate(render:() -> Child) {
		var generator = new Generator(this, render);
		return generator.generate();
	}

	public function serve(render:() -> Child) {
		return Task.reject(new Error(NotImplemented, 'Serving Bridge apps is not ready yet'));
	}
	#end

	public function dispose() {}
}
