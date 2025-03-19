package blok.bridge.module;

import blok.bridge.server.*;
import blok.bridge.server.StaticFileMiddleware;
import capsule.*;

class DevServerModule implements Module {
	public function new() {}

	public function provide(container:Container) {
		container.map(Target).to(DevServer).share();
		container.map(ClientBuilder).to(ClientBuilder).share();
		container.map(Generator).to(Generator).share();
		container.map(StaticExpiry).toDefault(100).share();
		container.map(StaticFileMiddleware).to(StaticFileMiddleware).share();

		container.when(AppMiddleware).resolved((files:StaticFileMiddleware) -> value.prepend(files));
	}
}
