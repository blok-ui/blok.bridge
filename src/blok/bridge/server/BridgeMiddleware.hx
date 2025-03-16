package blok.bridge.server;

import blok.html.server.*;
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
			var accepts = request.headers.find(Accept).map(header -> header.value).or('text/html');
			if (accepts.indexOf('text/html') < 0) return handler.process(request);

			var context = new BridgeRequest(config, request, visitor);

			return generator
				.generatePage(context)
				.next(document -> {
					var code = context.response.code;
					var headers = context.response.headers;

					if (!headers.has(ContentType)) {
						// @todo: more?
						headers = headers.with(new HeaderField(ContentType, 'text/html'));
					}

					new Response(code, headers, stringifyDocument(document));
				})
				.recover(e -> Future.immediate(new Response(e.code, [
					new HeaderField(ContentType, 'text/html')
				], e.message)));
		};
	}

	function stringifyDocument(document:NodePrimitive) {
		var head = document
			.find(el -> el.as(ElementPrimitive)?.tag == 'head', true)
			.or(() -> new ElementPrimitive('head'));
		var body = document
			.find(el -> el.as(ElementPrimitive)?.tag == 'body', true)
			.or(() -> new ElementPrimitive('body'));

		return '<!doctype html><html>${head.toString({includeTextMarkers: false})}${body.toString()}</html>';
	}
}
