package blok.bridge.project;

@:using(ProjectTarget.FlagValueTools)
enum FlagValue {
	VString(value:String);
	VInt(value:Int);
	VBool(value:Bool);
}

class FlagValueTools {
	public static function toString(value:FlagValue) {
		return switch value {
			case VString(value): value;
			case VInt(value): Std.string(value);
			case VBool(value): Std.string(value);
		}
	}
}

abstract FlagsMap(Map<String, FlagValue>) from Map<String, FlagValue> {
	@:from
	public static function fromJson(value:{}):FlagsMap {
		return [for (field in Reflect.fields(value)) field => switch Reflect.field(value, field) {
			case out if (out is Bool): VBool(out);
			case out if (out is Int): VInt(out);
			case out: VString(out);
		}];
	}

	public inline function new(?values) {
		this = values ?? new Map();
	}

	@:to
	public function toJson():{} {
		var out:Dynamic = {};
		for (field => value in this) Reflect.setField(out, field, switch value {
			case VString(value): value;
			case VInt(value): value;
			case VBool(value): value;
		});
		return out;
	}

	@:to
	public function toEntries():Array<String> {
		var out:Array<String> = [];
		for (flag => value in this) {
			if (flag == 'debug') {
				value.ifExtract(VBool(value), if (value) out.push('--debug'));
			} else if (flag == 'dce') {
				out.push('-dce ${value.toString()}');
			} else if (flag == 'macro') {
				out.push('--macro ${value}');
			} else if (value.match(VBool(true))) {
				out.push('-D $flag');
			} else {
				out.push('-D ${flag}=${value.toString()}');
			}
		}
		return out;
	}
}

enum abstract TargetType(String) from String {
	final Js = 'js';
	final Php = 'php';
	// @todo: more
}

class ProjectTargetHxml implements Config {
	@:prop public final name:String = null;
	@:prop public final cleanup:Bool = false;
}

class ProjectTargetType implements Config {
	@:prop public final type:TargetType;
	@:prop public final output:String;
}

class ProjectTarget implements Config {
	@:prop public final name:String;
	@:prop public final sources:Array<String> = [];
	@:json(from = FlagsMap.fromJson(value), to = value.toJson()) @:prop public final flags:FlagsMap = new FlagsMap();
	@:prop public final dependencies:Array<String> = [];
	@:prop public final main:String = null;
	@:prop public final target:ProjectTargetType = null;
	@:prop public final hxml:ProjectTargetHxml = null;
}
