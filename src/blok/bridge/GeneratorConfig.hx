package blok.bridge;

import hotdish.SemVer;

enum abstract HtmlGenerationStrategy(String) to String from String {
	final DirectoryWithIndexHtmlFile;
	final NamedHtmlFile;
}

class GeneratorConfig implements Config {
	/**
		This should point to a class implementing `blok.bridge.Bootstrap`. Think of this
		as Bridge's `main` function. This is only important if you're using the Hotdish build
		system.

		Defaults to `Routes`.
	**/
	@:prop public final bootstrap:String = 'Routes';

	/**
		The current version of your app. This can be used to name generated files, which can
		assist with cache busting.
	**/
	@:prop public final version:SemVer = '0.0.1';

	/**
		The path generated artifacts should be saved. This includes things like a JSON manifest
		that lists all islands that need to be hydrated by the client app and generated haxe
		files used by the Hotdish build system.

		Defaults to `artifacts`.
	**/
	@:prop public final artifactPath:String = 'artifacts';

	/**
		The name of the JSON manifest that will contain a list of Islands used by your app
		(among other things in the future).
	**/
	@:prop public final manifestName:String = 'blok-bridge-manifest';

	/**
		The naming strategy to use when creating static HTML files. If your host allows
		stripping `html` from file names, you can set this to `NamedHtmlFile` for a 
		flatter file structure. Otherwise, this will generate folders for each matched route
		with an `index.html` file inside.
	**/
	@:prop public final strategy:HtmlGenerationStrategy = DirectoryWithIndexHtmlFile;
}
