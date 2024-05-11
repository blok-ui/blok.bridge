package blok.bridge;

import haxe.macro.Compiler;

enum abstract HtmlGenerationStrategy(String) to String {
	final DirectoryWithIndexHtmlFile;
	final NamedHtmlFile;
}

class AppConfig implements Config {
	public static function fromCompiler() {
		return new AppConfig({
			strategy: Compiler.getDefine('blok.generator.strategy'),
			paths: new PathsConfig({
				dataDirectory: Compiler.getDefine('blok.paths.data'),
				privateDirectory: Compiler.getDefine('blok.paths.private'),
				publicDirectory: Compiler.getDefine('blok.paths.public'),
				assetsPath: Compiler.getDefine('blok.paths.assets'),
			})
		});
	}

	@:prop public final strategy:HtmlGenerationStrategy = DirectoryWithIndexHtmlFile;
	@:prop public final paths:PathsConfig = new PathsConfig({});

	@:json(from = SerializableMap.fromJson(value), to = value.toJson())
	@:prop final options:SerializableMap = new SerializableMap([]);

	public function getOption(key:String):Maybe<String> {
		return options.get(key).toMaybe();
	}
}
