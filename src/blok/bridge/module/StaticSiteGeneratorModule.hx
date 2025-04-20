package blok.bridge.module;

import blok.bridge.server.StaticSiteGenerator.HtmlGenerationStrategy;
import blok.bridge.server.*;
import capsule.*;

class StaticSiteGeneratorModule implements Module {
	public function new() {}

	public function provide(container:Container) {
		container.map(Generator).to(Generator).share();
		container.map(Target).to(StaticSiteGenerator).share();
		container.map(HtmlGenerationStrategy).toDefault(() -> DirectoryWithIndexHtmlFile).share();
	}
}
