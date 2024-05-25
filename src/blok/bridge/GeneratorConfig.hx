package blok.bridge;

import hotdish.SemVer;

enum abstract HtmlGenerationStrategy(String) to String from String {
	final DirectoryWithIndexHtmlFile;
	final NamedHtmlFile;
}

class GeneratorConfig implements Config {
	@:prop public final version:SemVer = '0.0.1';
	@:prop public final artifactPath:String = 'artifacts';
	@:prop public final manifestName:String = 'blok-bridge-manifest';
	@:prop public final strategy:HtmlGenerationStrategy = DirectoryWithIndexHtmlFile;
}
