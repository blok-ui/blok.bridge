package blok.bridge;

using Lambda;

abstract Plugins(Array<Plugin>) from Array<Plugin> {
	public function new(plugins) {
		this = plugins;
	}

	public function add(plugin:Plugin) {
		this.push(plugin);
	}

	public function render(app, child) {
		for (plugin in this) {
			child = plugin.render(app, child);
		}
		return child;
	}

	public function visited(app, path, document) {
		for (plugin in this) {
			plugin.visited(app, path, document);
		}
	}

	public function output(app):Task<Nothing> {
		return Task.parallel(...[for (plugin in this) plugin.output(app)]);
	}

	public function cleanup() {
		for (plugin in this) plugin.cleanup();
	}
}
