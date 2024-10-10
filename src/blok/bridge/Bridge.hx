package blok.bridge;

#if !blok.client
import blok.bridge.util.*;
import blok.ui.Child;
import kit.file.*;
import kit.file.adaptor.*;
#end
import blok.data.Structure;

class Bridge extends Structure {
	#if blok.client
	public macro static function hydrateIslands();
	#else
	public macro static function trackIslands();

	public inline static function start(props) {
		trackIslands();
		return new Bridge(props);
	}

	@:constant public final fs:FileSystem = new FileSystem(new SysAdaptor(Sys.getCwd()));
	@:constant public final outputPath:String = 'dist/www';
	@:constant public final version:SemVer;

	public final events:Events;
	public final output:Directory;

	public function new() {
		events = new Events();
		output = fs.directory(outputPath);
	}

	public function plugin(plugin:Plugin) {
		plugin.register(this);
		return this;
	}

	public function plugins(plugins:Array<Plugin>) {
		for (plugin in plugins) this.plugin(plugin);
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
}
