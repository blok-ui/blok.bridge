import blok.bridge.*;
import blok.bridge.hotdish.*;
import hotdish.*;
import hotdish.node.*;

// This is an example of how to use the Hotdish build system
// to create a Blok Bridge app.
//
// Note that this is a bit of a mess: Hotdish is not really ready
// for use yet.
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
					{name: 'breeze'}
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
							flags: {
								'breeze.output': 'cwd:dist/public/assets/styles_${version.toFileNameSafeString()}'
							},
							children: [
								// We could output our build script somewhere,
								// but it's simpler just to *Run* it.
								new Run({}),
								// We need to also output an HXML file for our
								// IDE to point at. We want all our dependencies for
								// server builds here, NOT for client-side stuff.
								new Hxml({
									name: 'build-example'
								})
							]
						}),
						// Configure our client build step. Note that this is optional,
						// and only needed if we have client-only flags.
						client: new BuildClient({
							flags: {
								'breeze.output': 'none'
							}
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
