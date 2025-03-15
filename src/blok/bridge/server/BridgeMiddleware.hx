package blok.bridge.server;

import blok.bridge.server.Generator;
import blok.router.RouteVisitor;
import kit.http.*;

class BridgeMiddleware implements Middleware {
	public final config:Config;
	public final generator:Generator;
	public final visitor:RouteVisitor;

	public function new(config, generator, visitor) {
		this.config = config;
		this.generator = generator;
		this.visitor = visitor;
	}

	public function apply(handler:Handler):Handler {
		return request -> {
			// @todo: better validation
			var type = request.headers.find(Accept).map(header -> header.value).or('text/html');

			if (type.indexOf('text/html') < 0) return handler.process(request);

			// @todo: Our request thingie here should also let us setup response settings,
			// like adding headers or changing the HTTP code. See solid-start for inspiration.
			var bridgeRequest = new BridgeRequest(config, request, visitor);

			return generator.generatePage(bridgeRequest)
				.next(document -> new Response(OK, [
					new HeaderField(ContentType, 'text/html')
						// @todo: more header fields?
				], document.toString()))
				.recover(e -> Future.immediate(new Response(e.code, [
					new HeaderField(ContentType, 'text/html')
				], e.message)));
		};
	}
}
