package blok.bridge.server;

import kit.http.Handler;
import kit.http.*;

class BridgeMiddleware implements Middleware {
  final bridge:Bridge;

  public function new(bridge) {
    this.bridge = bridge;
  }

  public function apply(handler:Handler):Handler {
    return new BridgeHandler(bridge, handler);
  }
}

class BridgeHandler implements HandlerObject {
  final bridge:Bridge;
  final handler:Handler;

  public function new(bridge, handler) {
    this.bridge = bridge;
    this.handler = handler;
  }

  public function process(request:Request):Future<Response> {
    // @todo: try to match endpoints and generate a JSON response.
    return handler.process(request);
  }
}
