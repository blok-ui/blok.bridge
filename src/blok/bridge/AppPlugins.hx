package blok.bridge;

import blok.bridge.Plugin;

abstract AppPlugins(Array<Plugin>) {
	public function new(plugins) {
		this = plugins;
	}

	public function append(plugin) {
		this.push(plugin);
		return abstract;
	}

	public function prepend(plugin) {
		this.unshift(plugin);
		return abstract;
	}

	public function apply() {
		return Task.parallel(...this.map(plugin -> plugin.apply()));
	}
}
