package blok.bridge.module;

import blok.bridge.server.StaticSiteGenerator.HtmlGenerationStrategy;
import blok.bridge.server.*;
import blok.router.RouteVisitor;
import capsule.*;

class StaticSiteGeneratorModule implements Module {
	public function new() {}

	public function provide(container:Container) {
		container.map(RouteVisitor).to(RouteVisitor).share();
		container.map(Generator).to(Generator).share();
		container.map(Target).to(StaticSiteGenerator).share();
		container.map(HtmlGenerationStrategy).toDefault(() -> DirectoryWithIndexHtmlFile).share();

		// Expose the RouteVisitor to our components allowing all our routes
		// to be tracked. This is essential to making the static site generator work.
		container.when(AppProviders).resolved((visitor:RouteVisitor) -> value.add(visitor));
	}
}
