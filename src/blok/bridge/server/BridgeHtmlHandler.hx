package blok.bridge.server;

import kit.http.Handler;
import kit.http.*;

class BridgeHtmlHandler implements HandlerObject {
  final bridge:Bridge;

  public function new(bridge) {
    this.bridge = bridge;
  }

  public function process(request:Request):kit.Future<Response> {
    return bridge.mount()
      .next(document -> new Response(OK, [
        new HeaderField(ContentType, 'text/html')
      ], document.toString()))
      // @todo: Figure out how to handle error responses.
      .recover(error -> Future.immediate(new Response(error.code, [
        new HeaderField(ContentType, 'text/html')
      ], error.message)));
  }
}
