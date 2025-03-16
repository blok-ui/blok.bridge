package blok.bridge;

import blok.debug.Debug;
import blok.router.RouteVisitor;
import kit.http.*;

@:fallback(error('No BridgeRequest found'))
class RequestContext implements Context {
	public final config:Config;
	public final request:Request;
	public final response:ResponseStub = new ResponseStub();
	public final visitor:RouteVisitor;

	public function new(config, request, visitor) {
		this.config = config;
		this.request = request;
		this.visitor = visitor;
	}

	public function dispose() {}
}

class ResponseStub {
	public var code:StatusCode = OK;
	public final headers:Headers = [];

	public function new() {}
}
