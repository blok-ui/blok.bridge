package blok.bridge;

import haxe.macro.Compiler;

class AppConfig implements Config {
	public static function fromCompiler() {
		return new AppConfig({
			generator: new GeneratorConfig({
				version: (Compiler.getDefine('blok.generator.version') : String),
				strategy: (Compiler.getDefine('blok.generator.strategy') : String),
				artifactPath: Compiler.getDefine('blok.generator.artifacts'),
				manifestName: Compiler.getDefine('blok.generator.manifest')
			}),
			paths: new PathsConfig({
				dataDirectory: Compiler.getDefine('blok.paths.data'),
				privateDirectory: Compiler.getDefine('blok.paths.private'),
				publicDirectory: Compiler.getDefine('blok.paths.public'),
				assetsPath: Compiler.getDefine('blok.paths.assets'),
			})
		});
	}

	// @:prop public final version:SemVer;
	// @:prop public final strategy:HtmlGenerationStrategy = DirectoryWithIndexHtmlFile;
	@:prop public final generator:GeneratorConfig;
	@:prop public final paths:PathsConfig = new PathsConfig({});

	@:json(from = SerializableMap.fromJson(value), to = value.toJson())
	@:prop final options:SerializableMap = new SerializableMap([]);

	public function getOption(key:String):Maybe<String> {
		return options.get(key).toMaybe();
	}

	public function getClientAppName() {
		return '__app_' + generator.version.toFileNameSafeString() + '.js';
	}
}
