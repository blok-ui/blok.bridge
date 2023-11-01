package blok.bridge;

// @todo: This should be a component that correctly hooks into
// the component lifecycle.
class Archipelago {
  macro public static function wrap(packages, child) {
    return blok.bridge.ArchipelagoBuilder.createWrapper(packages, child);
  }
}
