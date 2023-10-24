package blok.bridge.routing;

import haxe.Json;
import kit.http.*;
import haxe.io.Bytes;

function withErrorResponse(task:Task<Response>):Future<Response> {
  return task.map(res -> switch res {
    case Ok(value): 
      value;
    case Error(error):
      toJsonErrorResponse(error);
  });
}

function toJsonErrorResponse(error:Error) {
  return new Response(error.code, [
    new HeaderField(ContentType, 'application/json')
  ], Json.stringify({
    error: {
      code: error.code,
      message: error.message
    }
  }).pipe(Bytes.ofString(_)));
}
