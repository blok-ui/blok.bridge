package blok.bridge.plugin;

import blok.bridge.util.TaskQueue;
import blok.bridge.Constants;
import blok.bridge.util.Sources;

using blok.bridge.util.Commands;
using haxe.io.Path;

enum ClientAppDependencies {
	InheritDependencies;
	UseHxml(path:String);
	UseCustom(deps:Array<{name:String, ?version:String}>);
}

enum ClientAppNamingStrategy {
	UseAppVersion(prefix:String);
	UseName(name:String);
}

// private final mainContents = '// THIS IS A GENERATED FILE.
// // DO NOT EDIT.
// function main() {
//   #if blok.client
// 	blok.bridge.Bridge.hydrateIslands();
//   #end
// }';

class ClientApp extends Plugin {
	@:noUsing
	public static function maybeFrom(plugin:Plugin) {
		return plugin.findAncestorOfType(ClientApp);
	}

	@:value final target:String = '/assets/app';
	// @:value final main:String = 'BridgeIslands';
	@:value final sources:Array<String> = ['src'];
	@:value final dependencies:ClientAppDependencies = InheritDependencies;
	@:value final flags:Array<String> = [];
	@:value final minify:Bool = false;
	@:value final children:Array<Plugin> = [];

	public final onBuilt = new Event<String, TaskQueue>();

	public function run() {
		var target = target.normalize().withExtension('js');
		var core = Core.from(this);
		var output = Output.from(this);

		registerChild(new Assets({
			assets: [
				JsAsset((switch minify {
					case true: target.withExtension('min.js');
					default: target;
				}) + '?${core.bridge.version.toFileNameSafeString()}'),
				#if debug
				TrackedFile(target + '.map')
				#end
			]
		}));

		for (child in children) registerChild(child);

		output.exporting.add(queue -> {
			var task = output.directory.getMeta().next(meta -> {
				var target = Path.join([meta.path, target]).withExtension('js');
				// var mainPath = Path.join([DotBridge, IslandsMain]).withExtension('hx');

				return new Task(activate -> switch Sys.command(createHaxeCommand(target)) {
					case 0: activate(Ok(Nothing));
					case _: activate(Error(new Error(InternalError, 'Failed to generate haxe file')));
				})
					.next(_ -> if (minify) switch Sys.command(createMinifyCommand(target)) {
						case 0: Nothing;
						case _: new Error(InternalError, 'Failed to minify target');
					} else Nothing)
					.next(_ -> {
						Logging.maybeFrom(this).inspect(logger -> logger.log(Info, 'Client app built successfully'));
						var queue = new TaskQueue();
						onBuilt.dispatch(target, queue);
						queue.parallel();
					});
			});

			queue.enqueue(task);
		});
	}

	function createHaxeCommand(target:String) {
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

		cmd.push('-D blok.client');
		cmd.push('-main ${IslandsMain}');
		cmd.push('-js ${target}');

		return cmd.join(' ');
	}

	// @todo: Probably need to improve this so that we can use things
	// other than just uglifyjs.
	function createMinifyCommand(path:String) {
		return [
			'uglifyjs'.createNodeCommand(),
			path,
			'--compress',
			'--mangle',
			'-o ' + path.withExtension('min.js')
		].join(' ');
	}
}
