package blok.bridge.project.loader;

import blok.bridge.project.Project;
import kit.file.*;

class TomlProjectLoader implements ProjectLoader {
  final fs:FileSystem;

  public function new(fs) {
    this.fs = fs;
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
      .next((data:Dynamic) -> Project.fromJson(data));
  }
}
