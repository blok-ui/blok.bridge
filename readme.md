Blok Bridge
===========

Server-only functions for Blok.

Usage
-----

> Note: this is a notional example only.

```haxe
import blok.ui.*;
import blok.data.*;
import blok.bridge.*;

using Kit;
using blok.suspense.SuspenseModifiers;

class Foo extends Model {
  @:constant public final foo:String; 
}

// Fallbacks are required, just like with Contexts. 
@:fallback(new MyApi('fallback'))
class MyApi implements Api<'/api'> {
  public final prefix:String;

  public function new(prefix) {
    this.prefix = prefix;
  }

  @:endpoint(GET, '/foo')
  public function getFoo(value:String):Task<Foo> {
    return new Foo({
      foo: prefix + ' ' + value
    });
  }
}

class Example extends Component {
  // Note: this expands to: MyApi.getCurrent().__getFoo('bar');
  @:resource final foo:Foo = MyApi.getFoo('bar');

  function render() {
    return Html.div({}, foo().foo);
  }
}

function main() {
  var bridge = new Bridge([
    // Pass in all the endpoints we want:
    new MyApi('prefix')
  ], _ -> Example.node({}).inSuspense(() -> 'loading...'));
  var options:BridgeOptions = {
    jsPath: FromCompiler,
    hydrationId: '__bridge_data',
    rootId: 'root'
  };

  #if blok.server
  // This will serve our JSON api server:
  var server = new kit.http.server.NodeServer(3000);
  var mw = bridge.createMiddleware();
  var handler = new kit.http.Handler(req -> {
    return bridge.mount(options)
      .next(document -> new kit.http.Response(OK, [], document.toString()))
      .mapError(err -> new kit.http.Response(InternalError, [], err.message))
  });
  server.serve(handler.into(mw)).handle(mode -> switch mode {
		case Failed(e): trace(e);
		case Running(close): // todo
		case Closed: trace('closed');
	});
  // or you can just do this:
  bridge.serve(options);
  #else
  bridge.mount(options).handle(_ -> trace('Document ready'));
  // Or:
  bridge.hydrate(options);
  #end
}
```

Islands
-------

Another feature we can add are `IslandComponents`. IslandComponents look just like normal Components, but they require that all their properties be json serializable. Here's an example:

```haxe
package my.ui;

class Counter extends Component implements Island {
  @:signal final count:Int;

  function render() {
    return Html.div({},
      Html.span({}, 'Current count ', count),
      Html.button({ onClick: _ -> count.update(count -> count + 1) }, '+')
    );
  }
}
```

> note: IslandComponents can use normal components inside themselves -- they just act as a bridge.

This can be used inside a normal Component:

```haxe
package my.ui;

var App extends Component {
  function render() {
    return Html.div({}, Counter.island({ count: 1 }));
  }
}
```

When rendered on the server, the following HTML will be created:

```html
<div>
  <blok-island style="display:contents;" data-component="my.ui.Counter" data-props='{"count":1}'>
    <div>
      <span><!--#-->Current Count <!--#-->1</span>
      <button><!--#-->+</button>
    </div>
  </blok-island>
</div>
```

> Note: I *think* we don't need to define a custom element for this at all -- it should just work? Fairly sure this is what Leptos is doing, for example.

Instead of doing the usual `hydrate(root, () -> App.node({}))`, we instead use a special macro class:

```haxe
function main() {
  // By passing `'my.ui'` to `Islands`, we run a genericBuild macro
  // that scans the `my.ui` package and extracts all the `IslandComponents`
  // in it.
  var islands = new Islands<'my.ui'>();
  // Then we just call this:
  islands.hydrate();
}
```
