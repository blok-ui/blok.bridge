package ex.island;

import blok.bridge.*;
import blok.html.Html;
import blok.ui.*;

class Counter extends Island {
  @:signal final count:Int = 0;

  function render():Child {
    return Html.div()
      .child([
        Html.div().child(count),
        Html.button()
          .on(Click, _ -> count.update(i -> i + 1))
          .child('+')
      ]);
  }
}
