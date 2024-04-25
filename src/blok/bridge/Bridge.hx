package blok.bridge;

import haxe.macro.Compiler;
import blok.bridge.asset.*;

class Bridge {
	/**
		Startup a Bridge app using the default configuration/using
		configuration from compiler flags.
	**/
	public static function start(render, ?fs) {
		return build({
			strategy: Compiler.getDefine('blok.generator-strategy'),
			paths: new PathsConfig({
				dataDirectory: Compiler.getDefine('blok.paths.data'),
				privateDirectory: Compiler.getDefine('blok.paths.private'),
				publicDirectory: Compiler.getDefine('blok.paths.public'),
				assetsPath: Compiler.getDefine('blok.paths.assets'),
			})
		}, render, fs);
	}

	/**
		Startup a Bridge app.
	**/
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
