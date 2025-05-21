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
			if (!exists) return output.create().then(_ -> output.getMeta());
			output.getMeta();
		});
	}

	public function apply():Task<Nothing> {
		return ensureDirectory().then(meta -> {
			var target = Path.join([meta.path, config.clientName]).withExtension('js');
			var sources:Array<String> = [getDotBridgeDirectory()];
			var args = [];
			var libraries = ['blok.bridge'];
			var flags = [];

			switch config.clientDependencies {
				case InheritDependencies:
					logger.log(Warning, 'Attempting to use class paths from the server app to build the client app.');
					logger.log(Warning, 'This is HIGHLY UNSTABLE. It\'s very likely you\'ll encounter strange '
						+ 'compiler issues and hard to reason with bugs. Occasionally code will even compile but will '
						+ 'fail at runtime. If you run into problems, this option is probably the culprit. '
						+ 'Try switching to `UseHtml` (the preferred method) or `UseCustom`.'
					);
					var paths = Sources.getCurrentClassPaths().filter(path -> path != '' && path != null);
					sources = sources.concat(paths);
				case UseHxml(path):
					logger.log(Info, 'Building the client app using $path');
					args.push(path.withExtension('hxml'));
				case UseCustom(config):
					logger.log(Info, 'Building the client app using custom configuration');
					sources = sources.concat(config.sources);
					flags = flags.concat(config.flags);
					libraries = libraries.concat(config.deps.map(dep -> dep.name));
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
				.then(_ -> if (config.clientMinified) {
					logger.log(Info, 'Minifying client app');
					// @todo: Make it so we don't need to only use uglifyjs
					new Process('uglifyjs'.createNodeCommand(), [
						target,
						'--compress',
						'--mangle',
						'-o ' + target.withExtension('min.js')
					]).then(_ -> Task.nothing());
				} else {
					Task.nothing();
				})
				.then(_ -> {
					logger.log(Info, 'Client app built successfully');
					Task.nothing();
				});
		});
	}
}
