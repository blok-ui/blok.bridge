package blok.bridge.server;

import blok.bridge.Constants;
import blok.bridge.util.Sources;

using blok.bridge.util.Commands;
using haxe.io.Path;

class ClientBuilder {
	final config:Config;
	final output:OutputDirectory;
	final logger:Logger;

	public function new(config, output, logger) {
		this.config = config;
		this.output = output;
		this.logger = logger;
	}

	public function build():Task<Nothing> {
		return output.getMeta().next(meta -> {
			var target = Path.join([meta.path, config.clientName]).withExtension('js');

			return new Task(activate -> switch Sys.command(createHaxeCommand(target)) {
				case 0: activate(Ok(Nothing));
				case _: activate(Error(new Error(InternalError, 'Failed to generate haxe file')));
			})
				.next(_ -> if (config.clientMinified) switch Sys.command(createMinifyCommand(target)) {
					case 0: Nothing;
					case _: new Error(InternalError, 'Failed to minify target');
				} else Nothing)
				.next(_ -> {
					logger.log(Info, 'Client app built successfully');
					Task.nothing();
				});
		});
	}

	function createHaxeCommand(target:String) {
		var sources:Array<String> = config.clientSources.concat([DotBridge]);
		var cmd = ['haxe'.createNodeCommand()];
		var libraries = ['blok.bridge'];
		var flags = config.clientFlags.copy();

		switch config.clientDependencies {
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
