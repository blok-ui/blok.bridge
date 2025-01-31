package blok.bridge.plugin;

import kit.file.*;

class Cleanup extends Plugin {
	public function run() {
		Output.maybeFrom(this).inspect(output -> {
			var link = Lifecycle.from(this).cleanup.add(queue -> {
				queue.enqueue(cleanupDir(output.directory, output));
			});
			addDisposable(() -> link.cancel());
		});
	}

	function cleanupDir(dir:Directory, output:Output) {
		var logging = Logging.maybeFrom(this);

		return dir
			.listFiles()
			.next(files -> {
				if (files.length == 0) return Task.nothing();

				Task.parallel(...files.map(file -> file
					.getMeta()
					.next(meta -> if (!output.contains(meta.path)) {
						logging.inspect(logger -> logger.log(Info, 'Removing ${meta.path}'));
						file.remove().next(_ -> Task.nothing());
					} else {
						Task.nothing();
					})
				));
			})
			.next(_ -> dir
				.listDirectories()
				.next(dirs -> {
					if (dirs.length == 0) return Task.nothing();
					Task.parallel(...dirs.map(dir -> cleanupDir(dir, output)));
				})
			)
			.next(_ -> Task.nothing());
	}
}
