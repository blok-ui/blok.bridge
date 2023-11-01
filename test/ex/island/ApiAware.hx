package ex.island;

import blok.bridge.IslandComponent;
import blok.html.Html;
import ex.api.FooApi;

class ApiAware extends IslandComponent {
  @:attribute final str:String;
  @:resource final foo:String = FooApi.from(this).getFoo(str);

  function render() {
    return Html.div({}, foo());
  }
}
