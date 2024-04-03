package blok.bridge.project;

import blok.context.Context;

using StringTools;
using haxe.io.Path;

@:fallback(null)
class Project implements Context implements Config {
  public static macro function embed();

  @:prop public final name:String;

  @:prop 
  @:json(to = value.toString(), from = SemVer.parse(value))
  public final version:SemVer;

  @:prop
  @:json(to = value.toJson(), from = IslandConfig.fromJson(value))
  public final islands:IslandConfig = new IslandConfig({});
  
  @:prop 
  @:json(to = value.toJson(), from = PathsConfig.fromJson(value))
  public final paths:PathsConfig = new PathsConfig({});
  
  @:prop 
  @:json(to = value.toJson(), from = BuildConfig.fromJson(value))
  public final build:BuildConfig;

  public function toBuildServerHxml():String {
    var body = new StringBuf();
    
    body.add('# THIS FILE WAS GENERATED FROM A `project.toml`. DO NOT EDIT!\n');
    body.add('# To configure things, edit your `project.toml` and run\n');
    body.add('# `> bridge setup`.\n\n');
    body.add('# Note: for haxe completion support, point your editor at THIS file.\n\n');
    body.add('# Note: while it\'s recommended you use the Blok cli, you *can* generate\n');
    body.add('# or serve your site by running `node ${build.output}`.\n');
    body.add('# However, you generally should build your app using `> bridge dev`\n');
    body.add('# or `> bridge prod`.\n\n');

    for (flag in toFlags({ isClient: false })) {
      body.add(flag + '\n');
    }

    body.add('\n-main ${build.main}\n\n');
    body.add('-${build.target} ${paths.createPrivateOutputPath(build.output)}\n');

    return body.toString();
  }

  public function toFlags(options:{ isClient:Bool }):Array<String> {
    var cmd = [];
    var version = version.toFileNameSafeString();
    var dependencies = build.dependencies.shared.concat(switch options.isClient {
      case true: build.dependencies.client;
      case false: build.dependencies.server;
    });
    var flags = build.flags.shared.toEntries().concat(switch options.isClient {
      case true: build.flags.client.toEntries();
      case false: build.flags.server.toEntries();
    });

    if (!dependencies.contains('blok.bridge')) {
      dependencies.unshift('blok.bridge');
    }

    if (!options.isClient) {
      if (!dependencies.contains('kit.file')) {
        dependencies.push('kit.file');
      }
      if (!dependencies.contains('toml')) {
        dependencies.push('toml');
      }
    }

    for (src in build.sources) {
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

  public function getIslandOutputPath() {
    return paths.createAssetOutputPath(islands.output);
  }
  
  public function getIslandPath() {
    return paths.createAssetPath(islands.output);
  }
}

class PathsConfig implements Config {
  @:prop public final dataDirectory:String = 'data';
  @:prop public final privateDirectory:String = 'dist';
  @:prop public final publicDirectory:String = 'dist/public';
  @:prop public final assetsPath:String = 'assets';

  public function createAssetPath(path:String) {
    return Path.join([ '/', assetsPath, path ]);
  }

  public function createPrivateOutputPath(path:String) {
    return Path.join([ privateDirectory, path ]);
  }

  public function createPublicOutputPath(path:String) {
    return Path.join([ publicDirectory, path ]);
  }

  public function createAssetOutputPath(path:String) {
    return Path.join([ publicDirectory, assetsPath, path ]);
  }
}

class IslandConfig implements Config {
  @:prop public final main:String = 'Islands';
  @:prop public final output:String = 'app.js';
}

class BuildConfig implements Config {
  @:prop public final sources:Array<String> = [ 'src' ];
  @:prop public final main:String = 'App';
  @:prop public final target:String = 'js';
  @:prop public final output:String = 'dist/build.js';
  
  @:prop
  @:json(to = value.toJson(), from = FlagsConfig.fromJson(value)) 
  public final flags:FlagsConfig = new FlagsConfig({});

  @:prop
  @:json(to = value.toJson(), from = DependenciesConfig.fromJson(value))
  public final dependencies:DependenciesConfig = new DependenciesConfig({});
}

class FlagsConfig implements Config {
  @:prop
  @:json(from = FlagsMap.fromJson(value), to = value.toJson())
  public final shared:FlagsMap = [];

  @:prop
  @:json(from = FlagsMap.fromJson(value), to = value.toJson())
  public final client:FlagsMap = [];

  @:prop 
  @:json(from = FlagsMap.fromJson(value), to = value.toJson())
  public final server:FlagsMap = [];
}

abstract FlagsMap(Map<String, Dynamic>) from Map<String, Dynamic> {
  @:from
  public static function fromJson(value:{}):FlagsMap {
    return [ for (field in Reflect.fields(value)) field => Reflect.field(value, field) ];
  }
  
  @:to
  public function toJson():{} {
    var obj = {};
    for (key => v in this) Reflect.setField(obj, key, v);
    return obj;
  }

  @:to
  public function toEntries():Array<String> {
    var out:Array<String> = [];
    for (flag => value in this) {
      if (flag == 'debug') {
        if (value == 'true' || value == true) out.push('--debug');
      } else if (flag == 'dce') {
        out.push('-dce ${value}');
      } else if (flag == 'macro') {
        out.push('--macro ${value}');
      } else if (value == true) {
        out.push('-D $flag');
      } else {
        out.push('-D ${flag}=${value}');
      }
    }
    return out;
  }
}

class DependenciesConfig implements Config {
  @:prop public final shared:Array<String> = [];
  @:prop public final client:Array<String> = [];
  @:prop public final server:Array<String> = [];
}

// class DependenciesConfig implements Config {
//   @:prop public final shared:Array<Dependency> = [];
//   @:prop public final client:Array<Dependency> = [];
//   @:prop public final server:Array<Dependency> = [];
// }

// class Dependency implements Config {
//   @:prop public final name:String;
  
//   @:prop 
//   @:json(to = value.toString(), from = SemVer.parse(value))
//   public final version:SemVer;
// }
