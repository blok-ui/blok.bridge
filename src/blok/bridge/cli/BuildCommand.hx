package blok.bridge.cli;

import blok.bridge.project.Project;
import blok.bridge.project.loader.TomlProjectLoader;
import kit.cli.Command;

using blok.bridge.cli.CliTools;

class BuildCommand implements Command {
	final loader:TomlProjectLoader;

	public function new(loader) {
		this.loader = loader;
	}

	/**
		Build a project using the nearest `project.toml`.
	**/
	@:command
	function project() {
		return loader.load()
			.next(project -> {
				var paths = project.getPaths();
				var server = project.getServerTarget();
				var outputPath = paths.createPrivateOutputPath(server.target?.output ?? 'build.js');
				var cmd = [
					'haxe'.createNodeCommand(),
					'-main ${server.main}',
					'-${server.target?.type ?? 'js'} ${outputPath}'
				].concat(project.getBuildFlagsForServer()).join(' ');

				output.writeLn(cmd);
				output.writeLn('Compiling...');

				var code = try Sys.command(cmd) catch (e) {
					return new Error(InternalError, e.message);
				}
				if (code == 0) {
					output.writeLn('Compiled.');
				} else {
					return new Error(InternalError, 'Compile failed');
				}

				return doGenerate(project);
			});
	}

	/**
		Generate an app without re-compiling the builder.
	**/
	@:command
	function generate() {
		return loader.load().next(doGenerate);
	}

	@:defaultCommand
	function help() {
		output.write(getDocs());
		return 0;
	}

	function doGenerate(project:Project):Task<Int> {
		var paths = project.getPaths();
		var server = project.getServerTarget();
		var outputPath = paths.createPrivateOutputPath(server.target?.output ?? 'build.js');

		output.writeLn('Generating...');
		var cmd = [
			'node',
			outputPath
		].join(' ');
		var code = try Sys.command(cmd) catch (e) {
			return new Error(InternalError, e.message);
		}
		if (code == 0) output.writeLn('Generated');

		return code;
	}
}
