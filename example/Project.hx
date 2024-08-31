import blok.bridge.hotdish.*;
import blok.bridge.plugin.*;
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
					// Use the BuildBridge node to set up the Bridge app.
					new BuildBridge({
						bootstrap: 'blog.Blog',
						version: version,
						// Configure our Server build.
						server: new BuildServer({
							dependencies: [
								{name: 'kit.file'},
								{name: 'toml'},
								{name: 'markdown'},
							],
							children: [
								new IncludeBreezeCss({
									children: [
										new StaticOutput({
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
					// in by seeing if there is a parent BuildServer node.
					'breeze.output': BuildServer.maybeFrom(this)
						.map(_ -> {
							var bridge = BuildBridge.from(this);
							var path = 'styles-${bridge.version.toFileNameSafeString()}.css';
							var fullPath = bridge.formatAssetOutputPath(path);

							// Configure bridge to automatically link to the generated
							// css file in our HTML output.
							var asset = new Asset({
								type: CssLink,
								path: bridge.formatAssetPath(path)
							});
							bridge.addPlugin(new LinkAssets({links: [asset]}));

							'cwd:$fullPath';
						})
						.or('none')
				},
				children: children
			})
		];
	}
}
