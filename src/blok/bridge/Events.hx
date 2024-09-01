package blok.bridge;

import blok.core.DisposableCollection;
import blok.html.server.NodePrimitive;
import blok.ui.Child;
import blok.bridge.util.*;

class Events {
	public final init = new Event<Void>();
	public final visited = new Event<String>();
	public final rendering = new Event<RenderEvent>();
	public final renderComplete = new Event<RenderCompleteEvent>();
	public final outputting = new Event<TaskQueue>();
	public final cleanup = new Event<DisposableCollection>();

	public function new() {}
}

class RenderEvent {
	public final path:String;

	var child:Child;

	public function new(path, child) {
		this.path = path;
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
