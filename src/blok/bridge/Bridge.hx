package blok.bridge;

import blok.bridge.asset.*;

class Bridge {
	public static function start(render, ?fs) {
		return build({}, render, fs);
	}

	public static function build(config, render, ?fs) {
		return new Bridge(new GeneratorConfig(config), render, fs);
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
}
