package blok.bridge;

import blok.macro.*;
import kit.macro.*;
import kit.macro.step.*;

function build() {
	return ClassBuilder.fromContext().addBundle(new PluginBuilder()).export();
}

class PluginBuilder implements BuildBundle {
	public function new() {}

	public function steps():Array<BuildStep> {
		return [
			new ValueFieldBuildStep(),
			new PropertyBuildStep(),
			new ConstructorBuildStep({})
		];
	}
}
