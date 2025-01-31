package blok.bridge;

#if !blok.client
import blok.bridge.util.*;
import blok.bridge.plugin.*;
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
	// public macro static function trackIslands();

	public inline static function start(props) {
		// trackIslands();
		return new Bridge(props);
	}

	@:value public final fs:FileSystem = new FileSystem(new SysAdaptor(Sys.getCwd()));
	@:value public final outputPath:String = 'dist/www';
	@:value public final version:SemVer;

	public final output:Directory;

	var plugins:Array<Plugin> = [];

	public function new() {
		output = fs.directory(outputPath);
	}

	public function use(...plugins:Plugin) {
		this.plugins = this.plugins.concat(plugins.toArray());
		return this;
	}

	public function generate() {
		var core = new Core({
			bridge: this,
			children: plugins
		});

		core.activate(null);

		return core
			.dispatch()
			.next(_ -> {
				core.dispose();
				Task.nothing();
			});
	}
	#end

	public function dispose() {}
}
