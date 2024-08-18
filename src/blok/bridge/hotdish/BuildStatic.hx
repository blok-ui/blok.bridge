package blok.bridge.hotdish;

import haxe.Template;
import blok.bridge.Constants;
import hotdish.Node;
import hotdish.node.Build;
import hotdish.node.*;

using haxe.io.Path;
using haxe.Json;

class BuildStatic extends Node {
	@:prop final main:String = 'BridgeGenerate';
	@:prop final sources:Array<String> = [];
	@:prop final dependencies:Array<Dependency> = [];
	@:prop final flags:BuildFlags = new BuildFlags();
	@:prop final children:Array<Node> = [new Run({})];

	public function build():Array<Node> {
		var bridge = BuildBridge.from(this);

		return [
			new Step({
				children: [
					new Artifact({
						path: Path.join([DotBridge, main]).withExtension('hx'),
						contents: template.execute({
							bootstrap: bridge.bootstrap,
							output: bridge.outputDirectory,
							assets: bridge.assetPrefix,
							version: bridge.version.toString(),
							clientAppPath: bridge.getClientAppPath(),
							strategy: bridge.strategy
						})
					})
				],
				then: () -> [new Build({
					main: main,
					sources: sources.concat([DotBridge]),
					dependencies: dependencies,
					flags: flags,
					macros: [
						'blok.bridge.macro.IslandIntrospector.run()'
					],
					children: children
				})]
			})
		];
	}
}

private final template = new Template('// THIS IS A GENERATED FILE.
// DO NOT EDIT.

function main() {
	#if !blok.client
	var fs = new kit.file.FileSystem(new kit.file.adaptor.SysAdaptor(Sys.getCwd()));
	var app = new blok.bridge.App({
		fs: fs,
		output: fs.directory("::output::"),
		version: "::version::",
		paths: new blok.bridge.Paths({
			assetPrefix: "::assets::", 
			clientApp: "::clientAppPath::"
		})
	});
	blok.bridge.Bridge.generate({
		app: app,
		render: () -> ::bootstrap::.node({}),
		strategy: ::strategy::
	});
	#end
}
');
