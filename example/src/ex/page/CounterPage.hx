package ex.page;

import ex.island.Counter;
import ex.layout.MainLayout;
import blok.ui.*;

class CounterPage extends Component {
  @:attribute final initialCount:Int;

  function render():Child {
    return MainLayout.node({
      children: Counter.node({ count: initialCount })
    });
  }
}
