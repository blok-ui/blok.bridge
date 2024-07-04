package blok.bridge;

import blok.bridge.asset.*;

class Bridge {
	#if blok.client
	public macro static function startIslands();
	#else

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

	/**
		Run a Bridge app using a Bootstrap class.

		Note: this is mostly intended for internal use. If you're not
		using Hotdish, you probably don't need to use this method.
	**/
	public static function use(bootstrap:Bootstrap) {
		return start(() -> bootstrap.start())
			.generate()
			.next(app -> app.process())
			.handle(result -> bootstrap.finish(result));
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
