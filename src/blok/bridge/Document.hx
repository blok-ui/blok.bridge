package blok.bridge;

abstract class Document {
  final options:DocumentOptions;

  public function new(options) {
    this.options = options;
  }

  public function getRootLayer() {
    return getLayer(options.rootId);
  }

  abstract public function getHead():Dynamic;
  abstract public function getBody():Dynamic;
  abstract public function getLayer(name:String):Dynamic;
  abstract public function toString():String;
}
