import blok.bridge.*;
import blok.bridge.hotdish.*;
import hotdish.*;
import hotdish.node.*;

using Kit;

// This is an example of how to use the Hotdish build system
// to create a Blok Bridge app.
function main() {
	var version = new SemVer(0, 0, 1);
	var project = new Project({
		name: 'blok.bridge.example',
		version: version,
		url: '',
		contributors: ['wartman'],
		license: 'MIT',
		description: 'An example app built with Hotdish and Blok Bridge',
		releasenote: 'Pre-release',
		children: [
			// Define shared dependencies with an outer Build node.
			new Build({
				sources: ['example/src'],
				flags: {
					'dce': 'full',
					'analyzer-optimize': true,
					'debug': true
				},
				dependencies: [
					{name: 'breeze'},
					{name: 'blok.foundation'}
				],
				children: [
					// Use the BlokBridge node to set up the Bridge app.
					new BlokBridge({
						config: new AppConfig({
							generator: new GeneratorConfig({
								bootstrap: 'blog.Routes',
								version: version
							})
						}),
						// Configure our Static file build.
						server: new BuildStatic({
							dependencies: [
								{name: 'kit.file'},
								{name: 'toml'},
								{name: 'markdown'},
							],
							children: [
								new IncludeBreezeCss({
									children: [
										// We could output our build script somewhere,
										// but it's simpler just to *Run* it.
										new Run({}),
										// We need to also output a HXML file for our
										// IDE to point at. We want all our dependencies for
										// server builds here, NOT for client-side stuff.
										new Hxml({
											name: 'build-example'
										})
									]
								})
							]
						}),
						// Configure our client build step. Note that this is optional,
						// and only needed if we have client-only flags.
						client: new BuildClient({
							children: [
								new IncludeBreezeCss({
									children: [
										new ClientOutput({})
									]
								})
							]
						})
					})
				]
			})
		]
	});

	project.run().handle(result -> switch result {
		case Ok(_): trace('Completed');
		case Error(error): trace(error.message);
	});
}

// This is a simple custom node to show how you might hook your own build steps
// into Hotdish. In this case, we're adding a node to handle Breeze output.
class IncludeBreezeCss extends Node {
	@:prop final children:Array<Node>;

	function build():Array<Node> {
		// Only output CSS in BuildStatic mode! We can check which build mode we're
		// in by seeing if there is a parent BuildStatic node.
		var outputCss = BuildStatic.maybeFrom(this).map(_ -> true).or(false);

		if (!outputCss) return [
			new Build({
				flags: {
					'breeze.output': 'none'
				},
				children: children
			})
		];

		var config = BlokBridge.from(this).config;
		var version = config.generator.version;
		var path = config.paths.createAssetOutputPath('styles_${version.toFileNameSafeString()}');

		return [
			new Build({
				flags: {
					'breeze.output': 'cwd:$path'
				},
				children: children
			})
		];
	}
}
