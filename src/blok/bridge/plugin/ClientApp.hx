package blok.bridge.plugin;

import blok.bridge.Constants;
import blok.bridge.util.Sources;
import blok.data.Structure;

using blok.bridge.util.Commands;
using haxe.io.Path;

enum ClientAppDependencies {
	InheritDependencies;
	UseHxml(path:String);
	UseCustom(deps:Array<{name:String, ?version:String}>);
}

enum ClientAppNamingStrategy {
	UseAppVersion(prefix:String);
	UseCustom(name:String);
}

// @todo: implement minify
class ClientApp extends Structure implements Plugin {
	@:constant final main:String = 'BridgeIslands';
	@:constant final sources:Array<String> = ['src'];
	@:constant final namingStrategy:ClientAppNamingStrategy = UseAppVersion('assets/app');
	@:constant final dependencies:ClientAppDependencies = InheritDependencies;
	@:constant final flags:Array<String> = [];
	@:constant final minify:Bool = false;

	public function register(bridge:Bridge) {
		bridge.plugin(new LinkedAssets([
			JsAsset(getAppName(bridge), true)
		]));

		bridge.events.outputting.add(event -> {
			var mainPath = Path.join([DotBridge, main]).withExtension('hx');
			var createMain = bridge.fs.file(mainPath).write('// THIS IS A GENERATED FILE.
// DO NOT EDIT.
function main() {
  #if blok.client
	blok.bridge.Bridge.hydrateIslands();
  #end
}');
			event.enqueue(createMain.next(_ -> switch Sys.command(createHaxeCommand(bridge)) {
				case 0: Nothing;
				case _: new Error(InternalError, 'Failed to generate haxe file');
			}));
		});
	}

	function getAppName(bridge:Bridge) {
		return switch namingStrategy {
			case UseCustom(name): name.withExtension('js');
			case UseAppVersion(prefix): (prefix + '-' + bridge.version.toFileNameSafeString()).withExtension('js');
		}
	}

	function createHaxeCommand(bridge:Bridge) {
		var sources:Array<String> = sources.concat([DotBridge]);
		var cmd = ['haxe'.createNodeCommand()];
		var libraries = ['blok.bridge'];
		var flags = this.flags.copy();

		switch dependencies {
			case InheritDependencies:
				var paths = Sources.getCurrentClassPaths().filter(path -> path != '' && path != null);
				sources = sources.concat(paths);
			case UseHxml(path):
				cmd.push(path.withExtension('hxml'));
			case UseCustom(deps):
				for (lib in deps) {
					libraries.push(lib.name);
				}
		}

		for (lib in libraries) {
			cmd.push('-lib $lib');
		}

		for (path in sources) {
			cmd.push('-cp $path');
		}

		cmd.push('-D js-es=6');
		cmd.push('-D message-reporting=pretty');

		#if debug
		cmd.push('--debug');
		#else
		cmd.push('--dce full');
		cmd.push('-D analyzer-optimize');
		#end

		for (flag in flags) {
			cmd.push(flag);
		}

		var target = Path.join([
			bridge.outputPath,
			getAppName(bridge)
		]).withExtension('js');

		cmd.push('-D blok.client');
		cmd.push('-main ${main}');
		cmd.push('-js ${target}');

		return cmd.join(' ');
	}
}
