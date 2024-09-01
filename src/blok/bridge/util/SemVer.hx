package blok.bridge.util;

abstract SemVer(Array<Int>) {
	@:from public static function parse(str:String):SemVer {
		var parts = str.split('.');
		return switch parts {
			// @todo: Support more than this.
			case [a, b, c]:
				new SemVer(Std.parseInt(a), Std.parseInt(b), Std.parseInt(c));
			default:
				throw 'Invalid format for semantic version.';
		}
	}

	public function new(major, minor, patch) {
		this = [major, minor, patch];
	}

	public var major(get, never):Int;

	inline function get_major():Int return this[0];

	public var minor(get, never):Int;

	inline function get_minor():Int return this[1];

	public var patch(get, never):Int;

	inline function get_patch():Int return this[2];

	@:to public function toString():String {
		return this.join('.');
	}

	public function toFileNameSafeString() {
		return 'v${this.join('_')}';
	}
}
