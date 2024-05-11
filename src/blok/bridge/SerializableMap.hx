package blok.bridge;

@:forward
abstract SerializableMap(Map<String, Dynamic>) from Map<String, Dynamic> {
	@:from public static function fromJson(data:{}) {
		return new SerializableMap([for (field in Reflect.fields(data))
			field => Reflect.field(data, field)
		]);
	}

	public function new(data) {
		this = data;
	}

	public function toJson() {
		var out = {};
		for (key => value in this) Reflect.setField(out, key, value);
		return out;
	}
}
