package blok.bridge;

class AppRunner {
	final plugins:AppPlugins;
	final target:Target;

	public function new(plugins, target) {
		this.plugins = plugins;
		this.target = target;
	}

	public function run():Task<Nothing> {
		return plugins.apply().then(_ -> target.run());
	}
}
