package blok.bridge.plugin;

import blok.bridge.util.*;

class Lifecycle extends Plugin {
	@:noUsing
	public static function from(plugin:Plugin) {
		return maybeFrom(plugin).orThrow('No Lifecycle plugin found');
	}

	@:noUsing
	public static function maybeFrom(plugin:Plugin) {
		return plugin.findAncestorOfType(Lifecycle);
	}

	@:value public final bridge:Bridge;

	public final setup = new Event<TaskQueue>();
	public final serve = new Event<TaskQueue>();
	public final commit = new Event<TaskQueue>();
	public final cleanup = new Event<TaskQueue>();

	@:value final children:Array<Plugin> = [];

	public function run() {
		registerChild(new Logging({
			#if bridge.no_logging
			logger: new blok.bridge.log.NullLogger(),
			#end
			children: [
				new Output({
					fs: bridge.fs,
					directory: bridge.output,
					children: children
				})
			]
		}));
	}

	public function dispatch() {
		var setupTasks = new TaskQueue();
		setup.dispatch(setupTasks);

		return setupTasks.parallel()
			.next(_ -> {
				var serveTasks = new TaskQueue();
				serve.dispatch(serveTasks);
				serveTasks.parallel();
			})
			.next(_ -> {
				var commitTasks = new TaskQueue();
				commit.dispatch(commitTasks);
				commitTasks.parallel();
			})
			.next(_ -> {
				var cleanupTasks = new TaskQueue();
				cleanup.dispatch(cleanupTasks);
				cleanupTasks.parallel();
			});
	}
}
