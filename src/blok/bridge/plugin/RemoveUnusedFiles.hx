package blok.bridge.plugin;

import kit.file.*;

using haxe.io.Path;

// @todo: This is not working yet.
class RemoveUnusedFiles implements Plugin {
	public function new() {}

	public function register(bridge:Bridge) {
		bridge.events.cleanup.add(event -> {
			event.enqueue(cleanupDir(bridge.output, event.getManifest()));
		});
	}

	function cleanupDir(dir:Directory, manifest:Array<String>) {
		return dir
			.listFiles()
			.next(files -> {
				if (files.length == 0) return Task.nothing();

				Task.parallel(...files.map(file -> file
					.getMeta()
					.next(meta -> if (!manifest.contains(meta.path)) {
						trace('REMOVE: ${meta.path}');
						// file.remove(); // @todo: We're turning this off until I'm more sure about this
						Task.nothing();
					} else {
						trace('OK: ${meta.path}');
						Task.nothing();
					})
				));
			})
			.next(_ -> dir
				.listDirectories()
				.next(dirs -> {
					if (dirs.length == 0) return Task.nothing();

					Task.parallel(...dirs.map(dir -> cleanupDir(dir, manifest)));
				})
			)
			.next(_ -> Task.nothing());
	}
}
