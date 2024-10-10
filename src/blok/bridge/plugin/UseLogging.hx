package blok.bridge.plugin;

import blok.bridge.log.DefaultLogger;
import blok.context.Provider;

// @todo: This is very basic for now. We'll add time stamps and stuff later.
class UseLogging implements Plugin {
	final logger:Logger;

	public function new(?logger) {
		this.logger = logger ?? new DefaultLogger();
	}

	public function register(bridge:Bridge) {
		bridge.events.rendering.add(event -> {
			event.apply(child -> Provider
				.provide(() -> new LoggerContext(logger))
				.child(_ -> child)
			);
		});

		bridge.events.init.add(() -> logger.log(Info, 'Generating app...'));

		bridge.events.visited.add(path -> logger.log(Info, 'Visiting $path'));

		bridge.events.renderSuspended.add((path, _) -> logger.log(Info, 'Suspended on $path'));

		bridge.events.renderComplete.add(event -> logger.log(Info, 'Completed ${event.path}'));

		bridge.events.renderFailed.add(exception -> logger.log(Error, exception.toString()));

		bridge.events.cleanup.add(event -> logger.log(Info, [
			'Generation complete. Output:'
		].concat(event.getManifest()).join('\n')));
	}
}
