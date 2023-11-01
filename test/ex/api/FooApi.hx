package ex.api;

import blok.bridge.Api;

using Kit;

@:fallback(new FooApi())
class FooApi implements Api<'/api'> {
  public function new() {}

  @:endpoint(Get)
  public function getFoo(foo:String):Task<String> {
    return foo;
  }

  @:endpoint(Post)
  public function getBar(bar:String):Task<String> {
    return bar;
  }
}
