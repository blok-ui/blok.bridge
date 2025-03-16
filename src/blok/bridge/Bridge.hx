package blok.bridge;

import blok.bridge.log.*;
import blok.bridge.module.*;
import blok.bridge.server.*;
import blok.bridge.util.*;
import capsule.Container;

class Bridge {
	public inline static function start(props) {
		return new Bridge(props);
	}

	final config:Config;
	final logger:Logger = new DefaultLogger();

	public function new(config) {
		this.config = new Config(config);
	}

	public function run(render) {
		switch config.target {
			case Static(_):
				generateStaticSite(render).handle(result -> switch result {
					case Ok(_): logger.log(Info, 'Site generation complete');
					case Error(error): logger.log(Error, error.toString());
				});
			case Server(port):
				serveDevSite(
					// @todo: handle non-node targets
					new kit.http.server.NodeServer(port),
					render
				).handle(result -> switch result {
					case Ok(status):
						switch status {
							case Failed(e):
								logger.log(Error, 'Failed to start server');
								Sys.exit(1);
							case Running(close):
								logger.log(Info, 'Serving app on http://localhost:${port}');
								Process.registerCloseHandler(() -> {
									logger.log(Info, 'Closing server...');
									close(status -> if (status) {
										logger.log(Info, 'Server closed');
									} else {
										logger.log(Info, 'Server closed badly');
									});
								});
							case Closed:
								Sys.exit(0);
						}
					case Error(error):
						logger.log(Error, error.message);
						Sys.exit(0);
				});
		}
	}

	public function generateStaticSite(render) {
		var container = Container.build(
			new CoreModule(config, render, logger),
			new StaticSiteModule()
		);

		var clientBuilder = container.get(ClientBuilder);
		var siteBuilder = container.get(StaticSiteBuilder);

		return clientBuilder.build()
			.next(_ -> siteBuilder.build());
	}

	public function serveDevSite(server, render) {
		var container = Container.build(
			new CoreModule(config, render, logger),
			new DevServerModule(server)
		);

		var clientBuilder = container.get(ClientBuilder);
		var devServer = container.get(DevServer);

		return clientBuilder.build()
			.next(_ -> devServer.serve());
	}
}
