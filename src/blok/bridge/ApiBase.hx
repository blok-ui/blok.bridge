package blok.bridge;

import kit.http.Response;

interface ApiBase {
  public function match(url:String):Maybe<Future<Response>>;
  public function makeCurrent():Void;
}
