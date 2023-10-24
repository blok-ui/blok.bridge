package blok.bridge;

// @todo: Consider if this *should* be a stand-alone IslandComponent.
// That would give us much more control.
@:autoBuild(blok.bridge.IslandBuilder.build())
interface Island {}
