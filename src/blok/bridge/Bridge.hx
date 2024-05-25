package blok.bridge;

import blok.bridge.asset.*;

class Bridge {
	public macro static function startIslands();

	#if !blok.client
	/**
		Startup a Bridge app using the default configuration/using
		configuration from compiler flags.
	**/
	public static function start(render, ?fs) {
		return new Bridge(AppConfig.fromCompiler(), render, fs);
	}

	/**
		Startup a Bridge app.
	**/
	public static function build(config, render, ?fs) {
		return new Bridge(new AppConfig(config), render, fs);
	}

	final generator:Generator;

	public function new(paths, render, ?fs) {
		this.generator = new Generator(paths, render, fs);
	}

	public function generate():Task<AppContext> {
		return generator.generate();
	}

	public function generatePage(path:String):Task<{
		html:HtmlAsset,
		app:AppContext
	}> {
		return generator.generatePage(path);
	}
	#end
}
