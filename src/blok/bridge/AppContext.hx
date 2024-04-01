package blok.bridge;

import blok.bridge.project.Project;
import blok.context.Context;
import blok.debug.Debug;
import kit.file.Directory;

using Lambda;

@:fallback(error('No AppContext found'))
class AppContext implements Context {
  public final project:Project;
  public final output:Directory;

  final assets:Array<Asset> = [];

  public function new(project, output) {
    this.project = project;
    this.output = output;
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
    return Task.parallel(...assets.map(asset -> asset.process(this)));
  }

  public function dispose() {}
}
