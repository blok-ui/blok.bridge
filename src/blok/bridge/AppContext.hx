package blok.bridge;

import blok.context.Context;
import blok.debug.Debug;
import kit.file.Directory;

using Lambda;

@:fallback(error('No AppContext found'))
class AppContext implements Context {
	public final config:AppConfig;
	public final privateDirectory:Directory;
	public final publicDirectory:Directory;

	final assets:Array<Asset> = [];

	public function new(config, privateDirectory, publicDirectory) {
		this.config = config;
		this.privateDirectory = privateDirectory;
		this.publicDirectory = publicDirectory;
	}

	public function addAsset(asset:Asset) {
		var id = asset.getIdentifier();
		if (id != null && assets.exists(asset -> asset.getIdentifier() == id)) {
			return;
		}
		if (!assets.contains(asset)) {
			assets.push(asset);
		}
	}

	public function process() {
		return Task
			.parallel(...assets.map(asset -> asset.process(this)))
			.next(_ -> this);
	}

	public function dispose() {}
}
