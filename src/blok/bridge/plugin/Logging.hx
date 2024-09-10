package blok.bridge.plugin;

// @todo: This is very basic for now. We'll add time stamps and stuff later.
class Logging implements Plugin {
	final log:(message:String) -> Void;

	public function new(?log) {
		this.log = log ?? msg -> trace(msg);
	}

	public function register(bridge:Bridge) {
		bridge.events.init.add(() -> log('Generating app...'));

		bridge.events.visited.add(path -> log('Visiting $path'));

		bridge.events.renderSuspended.add((path, _) -> log('Suspended on $path'));

		bridge.events.renderComplete.add(event -> log('Completed ${event.path}'));

		bridge.events.cleanup.add(event -> log([
			'Generation complete. Output:'
		].concat(event.getManifest()).join('\n')));
	}
}
