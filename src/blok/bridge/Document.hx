package blok.bridge;

abstract class Document {
  final options:DocumentOptions;

  public function new(options) {
    this.options = options;
  }

  public function getRootLayer() {
    return getLayer(options.rootId);
  }

  abstract public function getLayer<T>(name:String):T;
  abstract public function toString():String;
}