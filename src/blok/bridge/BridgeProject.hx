package blok.bridge;

import haxe.Json;
import blok.bridge.project.*;

using StringTools;

class BridgeProject implements Project implements Config {
	public static macro function embed();

	@:prop public final project:ProjectMeta;
	@:prop public final paths:ProjectPaths;
	@:prop public final build:BridgeProjectTargets;

	public function getMeta():ProjectMeta {
		return project;
	}

	public function getPaths():ProjectPaths {
		return paths;
	}

	public function getClientTarget():ProjectTarget {
		return build.client;
	}

	public function getServerTarget():ProjectTarget {
		return build.server;
	}

	public function getBuildFlagsForServer():Array<String> {
		return getBuildFlags(false);
	}

	public function getBuildFlagsForClient():Array<String> {
		return getBuildFlags(true);
	}

	public function createServerHxml():String {
		var body = new StringBuf();
		var outputPath = paths.createPrivateOutputPath(build.server.target.output);
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

		body.add('\n-main ${build.server.main}\n\n');
		body.add('-${build.server.target.type} ${outputPath}\n');

		return body.toString();
	}

	public function createHaxelibJson():String {
		var dependencies:{} = {};

		for (dep in build.server.dependencies) {
			Reflect.setField(dependencies, dep.name, dep.version.toString());
		}

		for (dep in build.shared.dependencies) {
			Reflect.setField(dependencies, dep.name, dep.version.toString());
		}

		var contents = {
			name: project.name,
			classPath: build.server.sources[0] ?? build.shared.sources[0] ?? 'src',
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
		var dependencies = build.shared.dependencies.concat(switch isClient {
			case true: build.client.dependencies;
			case false: build.server.dependencies;
		}).map(dep -> dep.name);
		var sources = build.shared.sources.concat(switch isClient {
			case true: build.client.sources;
			case false: build.server.sources;
		});
		var flags = build.shared.flags.toEntries().concat(switch isClient {
			case true: build.client.flags.toEntries();
			case false: build.server.flags.toEntries();
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
			// @todo: Should we make this work with other variables?
			cmd.push(flag.replace('{{version}}', version));
		}

		return cmd;
	}
}

class BridgeProjectTargets implements Config {
	@:prop public final shared:ProjectTarget;
	@:prop public final server:ProjectTarget;
	@:prop public final client:ProjectTarget;
}
