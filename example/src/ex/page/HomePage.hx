package ex.page;

import ex.layout.MainLayout;
import blok.html.Html;
import blok.ui.*;

class HomePage extends Component {
  function render():Child {
    return MainLayout.node({
      children: Html.div().child('home page').node()
    });
  }
}
