package blok.bridge.cli;

import haxe.Json;
import kit.file.adaptor.SysAdaptor;
import kit.file.FileSystem;
import blok.bridge.project.loader.*;

using kit.Cli;

class CliApp implements Command {
  public static function run() {
    var fs = new FileSystem(new SysAdaptor(Sys.getCwd()));
    var loader = new TomlProjectLoader(fs);
    Cli.fromSys().execute(new CliApp(fs, loader));
  }

  final fs:FileSystem;
  final loader:TomlProjectLoader;

  public function new(fs, loader) {
    this.fs = fs;
    this.loader = loader;
  }

  /**
  Setup HXML files based on your `build.toml` configuration.
  **/
  @:command
  function setup():Task<Int> {
    output.writeLn('Setting up...');
    return loader.load()
      .next(project -> fs
        .file('build-${project.name}.hxml')
        .write(project.toBuildServerHxml())
      )
      .next(_ -> {
        output.writeLn('Setup complete.');
        return 0;
      });
  }

  // /**
  // Compile a development version of the site.
  // **/
  // @:command
  // function dev() {
    
  // }

  @:defaultCommand
  function help():Task<Int> {
    output.write(getDocs());
    return 0;
  }
}
