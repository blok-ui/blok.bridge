package blok.bridge.routing;

import kit.http.Request;
import haxe.Json;

function getJsonPayload<T:{}>(request:Request):Maybe<T> {
  return request.body.map(body -> body.toBytes().toString().pipe(Json.parse(_)));
}
