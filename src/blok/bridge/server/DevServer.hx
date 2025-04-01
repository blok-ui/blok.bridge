package blok.bridge.server;

import blok.bridge.util.Process;
import kit.http.*;

// @todo: Ideally this will be some kind of simple CLI thing that will
// restart whenever a file changes?
class DevServer implements Target {
	final logger:Logger;
	final generator:Generator;
	final server:Server;
	final middleware:AppMiddleware;

	public function new(logger:Logger, generator:Generator, server, middleware) {
		this.logger = logger;
		this.generator = generator;
		this.server = server;
		this.middleware = middleware;
	}

	public function run():Task<Nothing> {
		var handler:Handler = request -> {
			return Future.immediate(new Response(NotFound, [
				new HeaderField(ContentType, 'text/html')
			], '<html>
				<title>Page Not Found</title>
				<body>
					<h1>Page Not Found</h1>
					<p>There\'s nothing here!</p>
					<aside>
						<p><b>Warning!</b></p>
						<p>This error handler is Bridge\'s default fallback. You should never see this in production.</p>
						<p>If you are seeing this, check that you have a catch-all route (using a "*" path) in your router.</p> 
					</aside>
				</body>
			</html>'));
		}

		return server
			.serve(handler.into(...middleware.unwrap()))
			.map(status -> switch status {
				case Failed(e):
					logger.log(Error, 'Failed to start server');
					Sys.exit(1);
					Nothing;
				case Running(close):
					// @todo: include the port we're using somehow here
					logger.log(Info, 'Serving app');
					// logger.log(Info, 'Serving app on http://localhost:${port}');
					Process.registerCloseHandler(() -> {
						logger.log(Info, 'Closing server...');
						close(status -> if (status) {
							logger.log(Info, 'Server closed');
							Sys.exit(0);
						} else {
							logger.log(Info, 'Server closed badly');
							Sys.exit(1);
						});
					});
					Nothing;
				case Closed:
					Sys.exit(0);
					Nothing;
			});
	}
}
