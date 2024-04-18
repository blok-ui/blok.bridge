package blok.bridge;

import blok.bridge.asset.*;
import blok.bridge.project.*;

class Bridge {
	/**
		Start your Bridge app using a project.toml for configuration. This is
		the recommended way to use Blok Bridge.
	**/
	public static macro function start(render, ?fs);

	/**
		Start your app using a custom loader for your project configuration.
	**/
	public static function fromLoader(loader:ProjectLoader, render, ?fs) {
		return loader
			.load()
			.next(project -> new Bridge(project, render, fs));
	}

	final generator:Generator;

	public function new(project, render, ?fs) {
		this.generator = new Generator(project, render, fs);
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
}
