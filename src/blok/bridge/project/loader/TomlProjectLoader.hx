package blok.bridge.project.loader;

import kit.file.*;

class TomlProjectLoader implements ProjectLoader {
	final fs:FileSystem;
	final factory:(data:{}) -> Project;

	public function new(fs, factory) {
		this.fs = fs;
		this.factory = factory;
	}

	public function load():Task<Project> {
		// @todo: This needs to be better.
		return fs.file('project.toml')
			.read()
			.next(contents -> try {
				Task.resolve(Toml.parse(contents));
			} catch (e) {
				new Error(InternalError, e.message);
			})
			.next((data:Dynamic) -> factory(data));
	}
}
