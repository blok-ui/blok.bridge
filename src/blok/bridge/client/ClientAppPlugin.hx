package blok.bridge.client;

import kit.file.FileMeta;
import blok.bridge.macro.BridgeConfig;
import blok.bridge.util.*;

using blok.bridge.util.Commands;
using haxe.io.Path;

class ClientAppPlugin implements Plugin {
	final config:Config;
	final output:OutputDirectory;
	final logger:Logger;

	public function new(config, output, logger) {
		this.config = config;
		this.output = output;
		this.logger = logger;
	}

	function ensureDirectory():Task<FileMeta> {
		return output.exists().flatMap(exists -> {
			if (!exists) return output.create().next(_ -> output.getMeta());
			output.getMeta();
		});
	}

	public function apply():Task<Nothing> {
		return ensureDirectory().next(meta -> {
			var target = Path.join([meta.path, config.clientName]).withExtension('js');
			var sources:Array<String> = config.clientSources.concat([getDotBridgeDirectory()]);
			var args = [];
			var libraries = ['blok.bridge'];
			var flags = config.clientFlags.copy();

			switch config.clientDependencies {
				case InheritDependencies:
					var paths = Sources.getCurrentClassPaths().filter(path -> path != '' && path != null);
					sources = sources.concat(paths);
				case UseHxml(path):
					args.push(path.withExtension('hxml'));
				case UseCustom(deps):
					for (lib in deps) {
						libraries.push(lib.name);
					}
			}

			for (lib in libraries) {
				args.push('-lib $lib');
			}

			for (path in sources) {
				args.push('-cp $path');
			}

			args.push('-D js-es=6');
			args.push('-D message-reporting=pretty');

			#if debug
			args.push('--debug');
			#else
			args.push('--dce full');
			args.push('-D analyzer-optimize');
			#end

			for (flag in flags) {
				args.push(flag);
			}

			args.push('-D blok.client');
			args.push('-main ${getIslandsMainName()}');
			args.push('-js ${target}');

			return new Process('haxe'.createNodeCommand(), args)
				.next(_ -> if (config.clientMinified) {
					logger.log(Info, 'Minifying client app');
					// @todo: Make it so we don't need to only use uglifyjs
					new Process('uglifyjs'.createNodeCommand(), [
						target,
						'--compress',
						'--mangle',
						'-o ' + target.withExtension('min.js')
					]).next(_ -> Task.nothing());
				} else {
					Task.nothing();
				})
				.next(_ -> {
					logger.log(Info, 'Client app built successfully');
					Task.nothing();
				});
		});
	}
}
