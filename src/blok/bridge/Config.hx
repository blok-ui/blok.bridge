package blok.bridge;

import blok.bridge.util.SemVer;
import blok.data.Object;

using haxe.io.Path;

enum ClientAppDependencies {
	InheritDependencies;
	UseHxml(path:String);
	UseCustom(deps:Array<{name:String, ?version:String}>);
}

class Config extends Object {
	@:value public final rootPath:String = Sys.getCwd();
	@:value public final outputPath:String = 'dist/www';
	@:value public final version:SemVer;
	@:value public final assetsDirectory:String = '/assets';
	@:value public final clientName:String = '/assets/app';
	@:value public final clientMinified:Bool = #if debug false #else true #end;
	@:prop(get = switch clientMinified {
			case true: clientName.withExtension('min.js');
			case false: clientName.withExtension('js');
		}) public final clientSrc:String;
	@:value public final clientSources:Array<String> = ['src'];
	@:value public final clientDependencies:ClientAppDependencies = InheritDependencies;
	@:value public final clientFlags:Array<String> = [];
}
