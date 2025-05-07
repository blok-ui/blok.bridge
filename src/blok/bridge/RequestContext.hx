package blok.bridge;

import blok.debug.Debug;
import kit.http.*;

@:fallback(error('No RequestContext found'))
class RequestContext implements Context {
	public final config:Config;
	public final request:Request;
	public final response:ResponseStub = new ResponseStub();

	public function new(config, request) {
		this.config = config;
		this.request = request;
	}

	public function dispose() {}
}

class ResponseStub {
	public var code:StatusCode = OK;
	public final headers:Headers = [];

	public function new() {}
}
