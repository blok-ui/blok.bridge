package blok.bridge;

import haxe.Json;

using kit.Hash;

class IslandContextResolver {
	public static function current() {
		static var resolver:Null<IslandContextResolver> = null;
		if (resolver == null) {
			resolver = new IslandContextResolver();
		}
		return resolver;
	}

	final contexts:Map<String, Dynamic> = [];

	public function new() {}

	public function resolve<T:Context>(prefix:String, json:{}, factory:(json:{}) -> T):T {
		var key = (prefix + Json.stringify(json)).hash();
		var existing = contexts.get(key);

		if (existing != null) return existing;

		var context = factory(json);
		contexts.set(key, context);
		return context;
	}
}
