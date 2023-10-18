package blok.bridge;

import blok.ui.Child;

#if blok.server
import blok.bridge.server.BridgeMiddleware;
#end

class Bridge {
  final endpoints:Array<ApiBase>;
  final handler:(bridge:Bridge)->Child;

  public function new(endpoints, handler) {
    this.endpoints = endpoints;
    this.handler = handler;
  }

  public function mount(?options:{}):Task<Document> {
    // @todo
    return null;
  }

  #if blok.server
  public function createMiddleware():BridgeMiddleware {
    // @todo
  }
  #end

  function makeApisCurrent() {
    for (api in endpoints) api.makeCurrent();
  }
}
