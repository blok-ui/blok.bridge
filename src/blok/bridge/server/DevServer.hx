package blok.bridge.server;

import kit.http.*;

// @todo: Ideally this will be some kind of simple CLI thing that will
// restart whenever a file changes?
class DevServer {
	final logger:Logger;
	final generator:Generator;
	final server:Server;
	final middleware:MiddlewareStack;

	public function new(logger:Logger, generator:Generator, server, middleware) {
		this.logger = logger;
		this.generator = generator;
		this.server = server;
		this.middleware = middleware;
	}

	public function serve() {
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

		return server.serve(handler.into(...middleware.unwrap()));
	}
}
