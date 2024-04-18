package blok.bridge.cli;

import blok.bridge.project.loader.*;
import kit.file.FileSystem;

using kit.Cli;

class SetupCommand implements Command {
	final fs:FileSystem;
	final loader:TomlProjectLoader;

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
		output.writeLn('Setting up...');
		return loader.load()
			.next(project -> fs
				.file('build-${project.getMeta().name}.hxml')
				.write(project.createServerHxml())
			)
			.next(_ -> {
				output.writeLn('Setup complete.');
				return 0;
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
