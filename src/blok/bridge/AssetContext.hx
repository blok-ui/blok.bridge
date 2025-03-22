package blok.bridge;

import blok.signal.*;
import blok.debug.Debug.error;

@:fallback(error('No AssetContext found'))
class AssetContext implements Context {
	final owner = new Owner();
	final assets:Signal<Array<Child>>;
	final resource:Resource<Children>;

	public function new() {
		Owner.capture(owner, {
			assets = new Signal([]);
			resource = new Resource(() -> Task.ok(assets()));
		});
	}

	public function add(asset) {
		assets.update(assets -> assets.concat([asset]));
	}

	public function list() {
		// Note: We're using a resource here because we want rendering to be suspended
		// whenever we add an asset.
		//
		// Not 1000% sure if this is needed?
		return resource();
	}

	public function dispose() {
		owner.dispose();
	}
}
