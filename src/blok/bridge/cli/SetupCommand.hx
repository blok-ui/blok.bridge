package blok.bridge.cli;

import blok.bridge.project.*;
import kit.file.FileSystem;

using kit.Cli;

class SetupCommand implements Command {
	final fs:FileSystem;
	final loader:ProjectLoader;

	public function new(fs, loader) {
		this.fs = fs;
		this.loader = loader;
	}

	/**
		Create HXML files based on your `project.toml` configuration.

		This is needed if you want code completion to work in your editor
		or IDE, but is not required to compile apps.
	**/
	@:command
	function hxml():Task<Int> {
		output.writeLn('Creating hxml file...');
		return loader.load()
			.next(project -> fs
				.file('build-${project.project.name}.hxml')
				.write(project.createServerHxml())
			)
			.next(_ -> {
				output.writeLn('Setup complete.');
				return 0;
			});
	}

	/**
		Generate or update a haxelib.json file.
	**/
	@:command
	function haxelib() {
		output.writeLn('Creating haxelib.json...');
		return loader.load()
			.next(project -> {
				// @todo: Not ready to output actual haxelib yet.
				return fs.file('haxelib-test.json')
					.write(project.createHaxelibJson())
					.next(_ -> {
						output.writeLn('Created.');
						return 0;
					});
			});
	}

	/**
		Various commands for setting up Bridge-based projects.
	**/
	@:defaultCommand
	function help():Task<Int> {
		output.write(getDocs());
		return 0;
	}
}
