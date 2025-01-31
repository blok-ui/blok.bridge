package blok.bridge;

import blok.debug.Debug;

enum PluginStatus {
	Pending;
	Disposed;
	Registered(parent:Null<Plugin>);
}

@:autoBuild(blok.bridge.PluginBuilder.build())
abstract class Plugin implements DisposableHost implements Disposable {
	@:noCompletion
	var __status:PluginStatus = Pending;

	@:noCompletion
	final __children:Array<Plugin> = [];

	@:noCompletion
	final __owner:Owner = new Owner();

	public var parent(get, never):Plugin;

	function get_parent() {
		return __status.extract(if (Registered(parent)) parent else error('Plugin is not ready'));
	}

	abstract public function run():Void;

	public function activate(parent:Null<Plugin>) {
		assert(__status == Pending);
		__status = Registered(parent);
		run();
	}

	public function findAncestor(match:(ancestor:Plugin) -> Bool):Maybe<Plugin> {
		var plugin = parent;
		if (plugin == null) return None;
		if (match(plugin)) return Some(plugin);
		return plugin.findAncestor(match);
	}

	public function findAncestorOfType<T:Plugin>(kind:Class<T>):Maybe<T> {
		var plugin = parent;
		if (plugin == null) return None;
		return switch (Std.downcast(plugin, kind) : Null<T>) {
			case null: plugin.findAncestorOfType(kind);
			case found: Some(cast found);
		}
	}

	public function registerChild(plugin:Plugin) {
		if (__children.contains(plugin)) return;

		assert(plugin.__status == Pending);

		__children.push(plugin);
		addDisposable(plugin);
		plugin.activate(this);
	}

	public function filterChildren(match:(child:Plugin) -> Bool, recursive:Bool = false):Array<Plugin> {
		var results:Array<Plugin> = [];

		for (child in __children) {
			if (match(child)) results.push(child);
			if (recursive) {
				results = results.concat(child.filterChildren(match, true));
			}
		}

		return results;
	}

	public function findChild(match:(child:Plugin) -> Bool, recursive:Bool = false):Maybe<Plugin> {
		for (child in __children) {
			if (match(child)) return Some(child);
		}

		if (recursive) for (child in __children) {
			switch child.findChild(match, true) {
				case None:
				case found: return found;
			}
		}

		return None;
	}

	public function addDisposable(disposable:DisposableItem) {
		__owner.addDisposable(disposable);
	}

	public function removeDisposable(disposable:DisposableItem) {
		__owner.removeDisposable(disposable);
	}

	public function dispose() {
		__status = Disposed;
		__owner.dispose();
	}
}
