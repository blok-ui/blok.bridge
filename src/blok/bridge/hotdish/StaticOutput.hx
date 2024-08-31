package blok.bridge.hotdish;

import haxe.Template;
import blok.bridge.Constants;
import hotdish.node.*;
import hotdish.*;

using haxe.io.Path;
using haxe.Json;

class StaticOutput extends Node {
	@:prop final children:Array<Node> = [new Run({})];

	public function build():Array<Node> {
		var bridge = BuildBridge.from(this);
		var build = BuildServer.from(this);

		return [
			new Step({
				children: [
					new Artifact({
						path: Path.join([DotBridge, build.main]).withExtension('hx'),
						contents: template.execute({
							bootstrap: bridge.bootstrap,
							output: bridge.outputDirectory,
							assets: bridge.assetPrefix,
							plugins: bridge.plugins
								.map(plugin -> '${plugin.getPluginIdentifier()}.fromJson(${plugin.toJson().stringify()})')
								.concat([
									'new blok.bridge.plugin.IncludeClientApp({src: "${bridge.getClientAppPath()}", minify: false})',
									'new blok.bridge.plugin.OutputHtml({strategy: ${bridge.strategy}})'
								]).join(',\n    '),
							version: bridge.version.toString(),
							clientAppPath: bridge.getClientAppPath()
						})
					})
				],
				then: () -> children
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
		version: "::version::"
	});
	blok.bridge.Bridge.generate(app, () -> ::bootstrap::.node({}), [
		::plugins::
	]);
	#end
}
');
