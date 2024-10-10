package blok.bridge;

import haxe.Exception;
import blok.core.*;
import blok.html.server.NodePrimitive;
import blok.ui.Child;
import blok.bridge.util.*;

class Events {
	public final init = new Event<Void>();
	public final visited = new Event<String>();
	public final rendering = new Event<RenderEvent>();
	public final renderSuspended = new Event<String, NodePrimitive>();
	public final renderComplete = new Event<RenderCompleteEvent>();
	public final renderFailed = new Event<Exception>();
	public final outputting = new Event<OutputEvent>();
	public final cleanup = new Event<CleanupEvent>();

	public function new() {}
}

class RenderEvent {
	public final path:String;
	public final document:NodePrimitive;

	var child:Child;

	public function new(path, document, child) {
		this.path = path;
		this.document = document;
		this.child = child;
	}

	public function apply(render:(child:Child) -> Child) {
		this.child = render(this.child);
	}

	public function unwrap() {
		return child;
	}
}

class RenderCompleteEvent {
	public final path:String;
	public final document:NodePrimitive;

	public function new(path, document) {
		this.path = path;
		this.document = document;
	}
}

class OutputEvent {
	final queue = new TaskQueue();
	final manifest:Array<String> = [];

	public function new() {}

	public function enqueue(task) {
		queue.enqueue(task);
	}

	public function includeFile(path) {
		if (!manifest.contains(path)) manifest.push(path);
	}

	public function getManifest() {
		return manifest.copy();
	}

	public function run() {
		return queue.parallel();
	}
}

class CleanupEvent implements DisposableHost implements Disposable {
	final manifest:Array<String>;
	final disposables = new DisposableCollection();
	final queue = new TaskQueue();

	public function new(manifest) {
		this.manifest = manifest;
	}

	public function enqueue(task) {
		queue.enqueue(task);
	}

	public function run() {
		return queue.parallel();
	}

	public function getManifest() {
		return manifest.copy();
	}

	public function addDisposable(disposable:DisposableItem) {
		disposables.addDisposable(disposable);
	}

	public function removeDisposable(disposable:DisposableItem) {
		disposables.removeDisposable(disposable);
	}

	public function dispose() {
		disposables.dispose();
	}
}
