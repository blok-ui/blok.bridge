package blok.bridge;

class AppRunner {
	final logger:Logger;
	final plugins:AppPlugins;
	final target:Target;

	public function new(logger, plugins, target) {
		this.logger = logger;
		this.plugins = plugins;
		this.target = target;
	}

	public function run():Task<Nothing> {
		return logger.work(() -> plugins.apply().then(_ -> target.run()));
	}
}
