package blok.bridge;

import blok.core.*;
import blok.Component;

@:autoBuild(blok.bridge.IslandBuilder.build())
abstract class Island implements ComponentLike implements DisposableHost {
	abstract function toJson():Dynamic;

	abstract function __islandName():String;

	@:noCompletion
	final __disposables:DisposableCollection = new DisposableCollection();

	public function investigate() {
		return new ComponentInvestigator(cast getView());
	}

	abstract public function render():Child;

	abstract public function setup():Void;

	public function addDisposable(disposable:DisposableItem) {
		__disposables.addDisposable(disposable);
	}

	public function removeDisposable(disposable:DisposableItem) {
		__disposables.removeDisposable(disposable);
	}
}
