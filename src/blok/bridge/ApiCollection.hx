package blok.bridge;

import kit.http.*;
import blok.context.*;

@:forward(iterator, keyValueIterator)
abstract ApiCollection(Array<ApiBase>) {
  public function new(apis) {
    this = apis;
  }

  public function add(api) {
    this.push(api);
  }

  @:to public function toContextFactories():Array<()->Providable> {
    return this.map(api -> () -> api.as(Providable));
  }

  #if blok.server
  public function match(request:Request):Maybe<Future<Response>> {
    for (api in this) switch api.match(request) {
      case Some(res): return Some(res);
      case None:
    }
    return None;
  }
  #end
}
