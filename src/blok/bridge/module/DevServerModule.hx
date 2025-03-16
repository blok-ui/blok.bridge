package blok.bridge.module;

import blok.bridge.server.*;
import blok.bridge.server.StaticFileMiddleware;
import blok.router.RouteVisitor;
import capsule.*;
import kit.http.Server;

class DevServerModule implements Module {
	final server:Server;

	public function new(server) {
		this.server = server;
	}

	public function provide(container:Container) {
		container.map(Server).to(server);
		// @todo: We need to make RouteVisitor optional -- it's not needed here.
		container.map(RouteVisitor).to(RouteVisitor).share();
		container.map(ClientBuilder).to(ClientBuilder).share();
		container.map(Generator).to(Generator).share();
		container.map(DevServer).to(DevServer);
		container.map(StaticExpiry).toDefault(100).share();
		container.map(StaticFileMiddleware).to(StaticFileMiddleware).share();

		container
			.getMapping(MiddlewareStack)
			.extend(stack -> stack.prepend(container.get(StaticFileMiddleware)));
	}
}
