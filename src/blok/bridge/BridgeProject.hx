package blok.bridge;

import haxe.Json;
import blok.bridge.project.*;

using StringTools;

class BridgeProject implements Project implements Config {
	public static macro function embed();

	@:prop public final project:ProjectMeta;
	@:prop public final paths:ProjectPaths;
	@:prop public final shared:ProjectTarget;
	@:prop public final server:ProjectTarget;
	@:prop public final client:ProjectTarget;

	public function getBuildFlagsForServer():Array<String> {
		return getBuildFlags(false);
	}

	public function getBuildFlagsForClient():Array<String> {
		return getBuildFlags(true);
	}

	public function createServerHxml():String {
		var body = new StringBuf();
		var outputPath = paths.createPrivateOutputPath(server.target.output);
		var message = [
			'THIS FILE WAS GENERATED FROM A `project.toml`. DO NOT EDIT!',
			'',
			'To configure things, edit your `project.toml` and run `$$ bridge setup`',
			'',
			'Note: for haxe completion support, point your editor at THIS file.',
			'',
			'Note: while it\'s recommended you use the Blok Bridge cli, you can',
			'generate or serve your site by running `$$ node ${outputPath}`.'
		];

		for (line in message) {
			body.add('# $line\n');
		}

		body.add('\n');

		for (flag in getBuildFlagsForServer()) {
			body.add(flag + '\n');
		}

		body.add('\n-main ${server.main}\n\n');
		body.add('-${server.target.type} ${outputPath}\n');

		return body.toString();
	}

	public function createHaxelibJson():String {
		var dependencies:{} = {};

		for (dep in server.dependencies) {
			Reflect.setField(dependencies, dep.name, dep.version.toString());
		}

		for (dep in shared.dependencies) {
			Reflect.setField(dependencies, dep.name, dep.version.toString());
		}

		var contents = {
			name: project.name,
			classPath: server.sources[0] ?? shared.sources[0] ?? 'src',
			license: project.license,
			tags: project.tags,
			contributors: project.contributors,
			version: project.version.toString(),
			releasenote: project.releasenote,
			dependencies: dependencies
		};

		return Json.stringify(contents, '  ');
	}

	function getBuildFlags(isClient:Bool) {
		var cmd = [];
		var version = project.version.toFileNameSafeString();
		var dependencies = shared.dependencies.concat(switch isClient {
			case true: client.dependencies;
			case false: server.dependencies;
		}).map(dep -> dep.name);
		var sources = shared.sources.concat(switch isClient {
			case true: client.sources;
			case false: server.sources;
		});
		var flags = shared.flags.toEntries().concat(switch isClient {
			case true: client.flags.toEntries();
			case false: server.flags.toEntries();
		});
		var builtin = ['blok.bridge'];

		for (dep in builtin) if (!dependencies.contains(dep)) {
			dependencies.unshift(dep);
		}

		if (!isClient) {
			if (!dependencies.contains('kit.file')) {
				dependencies.push('kit.file');
			}
			if (!dependencies.contains('toml')) {
				dependencies.push('toml');
			}
		}

		for (src in sources) {
			cmd.push('-cp $src');
		}

		for (lib in dependencies) {
			cmd.push('-lib $lib');
		}

		for (flag in flags) {
			cmd.push(replaceVariables([
				'version' => version,
				'public' => paths.publicDirectory,
				'assets' => paths.createPublicOutputPath(paths.assetsPath)
			], flag));
		}

		return cmd;
	}

	function replaceVariables(props:Map<String, String>, str:String) {
		for (key => value in props) {
			str = str.replace('{{$key}}', value);
		}
		return str;
	}
}
