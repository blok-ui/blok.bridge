package blok.bridge.server;

import kit.http.Handler;
import kit.http.*;

class BridgeApiMiddleware implements Middleware {
  final bridge:Bridge;

  public function new(bridge) {
    this.bridge = bridge;
  }

  public function apply(handler:Handler):Handler {
    return new BridgeApiHandler(bridge, handler);
  }
}

class BridgeApiHandler implements HandlerObject {
  final bridge:Bridge;
  final handler:Handler;

  public function new(bridge, handler) {
    this.bridge = bridge;
    this.handler = handler;
  }

  public function process(request:Request):Future<Response> {
    switch (bridge.apis.match(request)) {
      case Some(res): return res;
      case None:
    }

    return handler.process(request);
  }
}
