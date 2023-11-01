package blok.bridge;

import blok.context.*;
import kit.http.*;

interface ApiBase extends Providable {
  #if blok.server
  public function match(request:Request):Maybe<Future<Response>>;
  #end
}
