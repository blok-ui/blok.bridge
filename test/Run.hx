import blok.bridge.*;
import blok.html.*;
import ex.api.*;
import ex.island.*;

function main() {
  var bridge = new Bridge([
    new FooApi()
  ], _ -> Archipelago.wrap(ex.island, Html.div({},
    Counter.node({ count: 2 }),
    ApiAware.node({ str: 'ok' })
  )));
  bridge.mount().handle(res -> switch res {
    case Ok(doc): trace(doc.toString());
    case Error(e): trace(e.message);
  });
}
