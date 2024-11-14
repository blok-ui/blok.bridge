package blok.bridge.plugin;

class VisitNotFoundPage implements Plugin {
	public function new() {}

	public function register(bridge:Bridge) {
		bridge.events.init.add(init -> {
			switch init.mode {
				case GeneratingFullSite:
					init.visit('/404.html');
				default:
			}
		});
	}
}
