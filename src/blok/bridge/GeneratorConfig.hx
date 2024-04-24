package blok.bridge;

enum abstract HtmlGenerationStrategy(String) {
	final DirectoryWithIndexHtmlFile;
	final NamedHtmlFile;
}

class GeneratorConfig implements Config {
	@:prop public final strategy:HtmlGenerationStrategy = DirectoryWithIndexHtmlFile;
	@:prop public final paths:PathsConfig = new PathsConfig({});
}
