Blok Bridge
===========

Tools for making Blok apps that run on the server and the client.

Usage
-----

Bridge is currently just a static-site generator, although there may be other ways to run it in the future. It's designed to be simple to use and mostly configuration free (with a few trade-offs we'll get to).

Here's a simple Bridge app, using default configuration:

```haxe
// src/Main.hx
import blok.bridge.Bridge;
import blok.html.Html;
import blok.router.*;

function main() {
  Bridge
    .start(() -> Html.view(<>
      <head>
        <title>"Example App"</title>
      </head>

      <body>
        <Router routes={[
          new Route<'/'>(_ -> <p>"Home Page"</p>)
        ]}/>
      </body>
    </>))
    .generate()
    .next(app -> app.process())
    .handle(result -> switch result {
      case Ok(_): trace('Created');
      case Error(e): trace(e.message);
    });
}
```

While we *could* compile this into some target (and -- for bigger apps -- that may even be desireable), generally we can just run it with a configuration like the following:

```hxml
# run.hxml
-cp src

-lib kit.file
-lib blok.bridge

--run Main
```

Running this (`$ haxe run.hxml`) should output some HTML in the default output directory (`dist/public`).

Islands of Interactivity
------------------------

To add interactive elements to our site, we need to use special `Island` components and we need to ensure that we send the necessary javascript to the client.

To do this, lets first create a simple Counter island:

```haxe
import blok.bridge.*;
import blok.html.Html;
import blok.ui.*;

class Counter extends Island {
	@:signal final count:Int = 0;

	function render():Child {
    return Html.view(<div>
      <span>count</span>
      <button onClick={_ -> count.update(i -> i + 1)}>'+'</button>
    </div>);
	}
}
```

Then let's update our main file to include the Counter and a special `blok.bridge.BridgeClient` component: 

```haxe
import blok.bridge.*;
import blok.html.Html;
import blok.router.*;

function main() {
  Bridge
    .start(() -> Html.view(<>
      <head>
        <title>"Example App"</title>
      </head>

      <body>
        <Router routes={[
          new Route<'/'>(_ -> <Counter count={0} />)
        ]}/>
        <BridgeClient />
      </body>
    </>))
    .generate()
    .next(app -> app.process())
    .handle(result -> switch result {
      case Ok(_): trace('Created');
      case Error(e): trace(e.message);
    });
}
```

For our simple app, that's all that's needed!

> @todo: Lots more to explain.
