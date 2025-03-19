package blok.bridge;

class AppRunner {
	final plugins:AppPlugins;
	final target:Target;

	public function new(plugins, target) {
		this.plugins = plugins;
		this.target = target;
	}

	public function run() {
		return plugins.apply().next(_ -> target.run());
	}
}
