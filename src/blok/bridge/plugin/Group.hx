package blok.bridge.plugin;

class Group extends Plugin {
	@:value final children:Array<Plugin>;

	public function run() {
		for (child in children) registerChild(child);
	}
}
