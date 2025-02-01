package blok.bridge.plugin;

import blok.bridge.util.TaskQueue;
import kit.file.*;

class Output extends Plugin {
	@:noUsing
	public static function from(plugin:Plugin) {
		return maybeFrom(plugin).orThrow('No Output plugin found');
	}

	@:noUsing
	public static function maybeFrom(plugin:Plugin) {
		return plugin.findAncestorOfType(Output);
	}

	@:value public final fs:FileSystem;
	@:value public final directory:Directory;

	public final exporting = new Event<TaskQueue>();

	@:value final logOutput:Bool = true;
	@:value final children:Array<Plugin>;

	final paths:Array<String> = [];

	public function run() {
		for (child in children) registerChild(child);

		var link = Lifecycle.from(this).commit.add(queue -> {
			exporting.dispatch(queue);
		});
		addDisposable(() -> link.cancel());

		if (logOutput) Logging.maybeFrom(this).inspect(logger -> {
			var link = Lifecycle.from(this).cleanup.add(_ -> logger.log(Info, [
				'File output:'
			].concat(paths.map(path -> '    $path')).join('\n')));
			addDisposable(() -> link.cancel());
		});
	}

	public function write(path, content) {
		exporting.add(queue -> {
			var file = directory.file(path);

			Logging
				.maybeFrom(this)
				.inspect(logger -> logger.log(Debug, 'Writing file to $path'));

			queue.enqueue(file.getMeta().next(meta -> {
				include(meta.path);
				file.write(content);
			}));
		});
	}

	public function include(path:String) {
		if (paths.contains(path)) return;
		paths.push(path);
	}

	public function contains(path:String) {
		return paths.contains(path);
	}

	public function list() {
		return paths;
	}
}
