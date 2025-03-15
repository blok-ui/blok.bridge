package blok.bridge.module;

import blok.bridge.server.*;
import blok.router.RouteVisitor;
import capsule.*;

class StaticSiteModule implements Module {
	public function new() {}

	public function provide(container:Container) {
		container.map(RouteVisitor).to(RouteVisitor).share();
		container.map(ClientBuilder).to(ClientBuilder).share();
		container.map(Generator).to(Generator).share();
		container.map(StaticSiteBuilder).to(StaticSiteBuilder).share();
	}
}
