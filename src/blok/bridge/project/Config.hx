package blok.bridge.project;

import blok.core.Disposable;

@:autoBuild(blok.bridge.project.ConfigBuilder.build())
@:remove
interface Config extends Disposable {}
