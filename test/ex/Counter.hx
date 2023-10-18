package ex;

import blok.ui.*;
import blok.html.*;

class Counter extends Component implements Island {
  @:signal final count:Int;

  function render() {
    return Html.div({},
      Html.span({}, 'Current count ', count),
      Html.button({ onClick: _ -> count.update(count -> count + 1) }, '+')
    );
  }
}
