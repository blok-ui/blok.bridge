import blok.bridge.*;
import blok.bridge.hotdish.*;
import hotdish.*;
import hotdish.node.*;

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
						// and only needed if we have client-only setup we want to do.
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

	project.run()
		.handle(result -> result.inspect(_ -> trace('Compiled')).orThrow());
}

// This is a simple custom node to show how you might hook your own build steps
// into Hotdish. In this case, we're adding a node to handle Breeze output.
class IncludeBreezeCss extends Node {
	@:prop final children:Array<Node>;

	function build():Array<Node> {
		return [
			new Build({
				dependencies: [
					{name: 'breeze'},
				],
				flags: {
					// Only output CSS when we're building the static app! We can check which build mode we're
					// in by seeing if there is a parent BuildStatic node.
					'breeze.output': BuildStatic.maybeFrom(this).map(_ -> {
						var config = BlokBridge.from(this).config;
						var path = config.paths.createAssetOutputPath(config.applyVersionToFileName('styles.css'));
						'cwd:$path';
					}).or('none')
				},
				children: children
			})
		];
	}
}
