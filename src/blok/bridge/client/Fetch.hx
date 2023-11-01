package blok.bridge.client;

import js.Browser;
import haxe.Json;
import kit.http.*;
import kit.http.client.*;

using Reflect;

private final client = new BrowserClient({
  credentials: INCLUDE
});

function fetch<T:{}>(request:Request):Task<T> {
  var base:Url = Browser.location.origin;
  trace(base);
  var url = request.url.withScheme(base.scheme).withDomain(base.domain);
  return client.request(request.withUrl(url)).next(response -> {
    var data = response.body.unwrap()?.toBytes()?.toString();
    if (data == null) return new Error(NotFound, 'Empty response');
    try {
      return Task.resolve(Json.parse(data));
    } catch (e) {
      return new Error(InternalError, 'Json parse failed: ${e.message}');
    }
  });
}
