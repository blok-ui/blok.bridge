package ex.island;

import blok.bridge.*;
import blok.html.*;

class Counter extends IslandComponent {
  @:signal final count:Int;

  function render() {
    return Html.div({},
      Html.span({}, 'Current count ', count),
      Html.button({ onClick: _ -> count.update(count -> count + 1) }, '+')
    );
  }
}
