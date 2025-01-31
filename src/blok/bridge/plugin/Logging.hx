package blok.bridge.plugin;

import blok.bridge.log.DefaultLogger;

class Logging extends Plugin {
	@:noUsing
	public static function from(plugin:Plugin) {
		return maybeFrom(plugin).orThrow('No Logging plugin found');
	}

	@:noUsing
	public static function maybeFrom(plugin:Plugin) {
		return plugin.findAncestorOfType(Logging);
	}

	@:value public final logger:Logger = new DefaultLogger();
	@:value public final children:Array<Plugin> = [];

	public function log(level, message) {
		logger.log(level, message);
	}

	public function run() {
		for (child in children) registerChild(child);
	}
}
