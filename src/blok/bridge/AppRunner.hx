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
		logger.startWorking('Blok Bridge');
		return plugins.apply()
			.inspect(_ -> target.run())
			.inspect(_ -> logger.finishWork());
	}
}
