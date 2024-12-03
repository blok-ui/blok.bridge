# Blok Bridge

Tools for making Blok apps that run on the server and the client.

> Note: This project is in heavy development and could change completely at any time.

## Usage

At the moment, Bridge provides a way to create a static website with islands of interactivity, all using the same codebase. It was heavily influenced by React Server Components (in concept if not in implementation).

In the future it might also be possible to use Bridge with server-side rendering, but that's beyond the scope of the current project.

## Overview

### Setting Things Up

Bridge apps start with simple configuration and some optional plugins. Here's a minimal example:

```haxe
import blok.bridge.*;
import blok.bridge.CoreExtensions;

function main() {
  Bridge
    .start({
      version: '0.0.1',
      outputPath: 'dist/www'
    })
    .use(generateStaticSiteUsingDefaults())
    .generate(() -> example.Example.node({}))
    .handle(result -> switch result {
      case Ok(_): trace('Done!');
      case Error(error): trace(error.message);
    });
}
```

The entrypoint of our Bridge app is just a normal Component (called "Example" in this case):

```haxe
package example;

import blok.ui.*;
import blok.html.Html;
import blok.bridge.Bootstrap;

class Example extends Component {
  public function render():Child {
    return Html.view(<html>
      <head>
        <title>"Example"</title>
      </head>
      <body>
        <h1>"Hello world"</h1>
        <p>"Hey world."</p>
      </body>
    </html>);
  }
}
```

Instead of compiling your app to a target (although you certainly can do that!) you can just `--run` it:

```hxml
-cp src

-lib blok.bridge
-lib kit.file

--run Run
```

This will output static HTML to `dist/www` for every route in your app in addition to a client-side app inside `dist/www/assets`. Right now this is just a single `index.html` file and some javascript that does nothing, so let's dig into making our app more interesting. 

### Adding Routes

Bridge uses the Blok Router package to handle routes. It will automatically follow any links created using the `blok.router.Link` component and output static HTML for each. Here's what our app looks like with some routes:

```haxe
package example;

import blok.html.Html;
import blok.ui.Child;
import blok.router.*;
import blok.bridge.Bootstrap;

class Example extends Component {
  function render():Child {
    return Html.view(<html>
      <head>
        <title>"Example"</title>
      </head>
      <body>
        <header>
          <h3><Link url="/">"Example"</Link></h3>
          <nav>
            <ul>
              <li><Link url="/counter/1">"Start at 1"</Link></li>
              <li><Link url="/counter/2">"Start at 2"</Link></li>
            </ul>
          </nav>
        </header>
        <Router>
          <Route to="/">
            {_ -> <div>
              <h1>"Home"</h1>
              <p>"Hello world"</p>
            </div>}
          </Route>
          <Route to="/counter/{count:Int}">
            {params -> <div>
              <h1>"Counting " {params.count}</h1>
              <p>"Counter"</p>
            </div>}
          </Route>
          <fallback>{_ -> "Not found"}</fallback>
        </Router>
      </body>
    </html>);
  }
}
```

If you compile your app again you should see that html was generated for `/counter/1` and `/counter/2`.

> Note: Bridge doesn't have anything like a development server yet, so the DX here is not the best. For now, I've been using the `serve` package from npm to host the `dist/public` folder (but any similar solution should work). This does require you to reload the page every time you make a change -- no cool hot-module-reloading here -- but it works. This is a place I want to improve (and which will simply work by calling `serve` instead of `generate` in your `main` function), but it's lower down on the priority list.

This is starting to become useful, but still isn't much more exciting than just creating those HTML files yourself. Let's add a little interactivity.

### Islands

An `Island` is almost exactly like a standard Blok component, but it has a little extra magic that allows it to work on both the client and the server. Let's create a Counter component for our counter route:

```haxe
package example;

import blok.bridge.*;
import blok.ui.*;
import blok.html.Html;

class Counter extends Island {
  @:signal final count:Int = 0;

  function render():Child {
    return Html.view(<div>
      <p>count</p>
      <button onClick={_ -> count.update(i -> i + 1)}>"+"</button>
    </div>);
  }
}
```

...and update our start method:

```haxe
package example;

import blok.html.Html;
import blok.ui.Child;
import blok.router.*;
import blok.bridge.Bootstrap;

class Example extends Component {
  function render():Child {
    return Html.view(<html>
      <head>
        <title>"Example"</title>
      </head>
      <body>
        <header>
          <h3><Link url="/">"Example"</Link></h3>
          <nav>
            <ul>
              <li><Link url="/counter/1">"Start at 1"</Link></li>
              <li><Link url="/counter/2">"Start at 2"</Link></li>
            </ul>
          </nav>
        </header>
        <Router>
          <Route to="/">
            {_ -> <div>
              <h1>"Home"</h1>
              <p>"Hello world"</p>
            </div>}
          </Route>
          <Route to="/counter/{count:Int}">
            {params -> <div>
              <h1>"Counting " {params.count}</h1>
              // Add our Counter here:
              <Counter count={params.count} />
            </div>}
          </Route>
          <Route to="*">{_ -> "Not found"}</fallback>
        </Router>
      </body>
    </html>);
  }
}
```

Recompile your app, visit the counter route and click on the `+` button. It should start counting up.

### Advanced Islands

If you inspect the HTML on the counter page, you'll see that it's wrapped in a `<blok-island>` custom element. You should also see that it has a `data-props` attribute that contains the initial count for the Counter component. This is how Blok handles hydration -- the props of the Island are serialized in the static HTML.

You may be curious what happens if you try to pass children to an Island. Let's update our example and find out:

```haxe
import blok.bridge.*;
import blok.ui.*;
import blok.html.Html;

class Counter extends Island {
  @:signal final count:Int = 0;
  @:attribute final label:Children;

  function render():Child {
    return Html.view(<div>
      <p>{label} ": " {count}</p>
      <button onClick={_ -> count.update(i -> i + 1)}>"+"</button>
    </div>);
  }
}
```

Let's make this a little more interesting and also create a Label component (it won't do anything special, we just need it for an explanation):

```haxe
import blok.ui.*;
import blok.html.Html;

class Label extends Component {
  @:children @:attribute final child:Child;
  
  function render() {
    return Html.view(<b>child</b>);
  }
}
```

Now lets update our counter route:

```haxe
<Route to="/counter/{count:Int}">
  {params -> <div>
    <h1>"Counting " {params.count}</h1>
    <Counter label={<Label>"Starting count at:" {params.count}</Label>} count={params.count} />
  </div>}
</Route>
```

When you compile the app again, this should just work! If you take a peek at the html again, you'll see that the children in the `label` attribute have been serialized to a very simple JSON representation. Importantly, however, there is no sign of the `Label` component -- Bridge has pre-rendered it and _only_ sent the resulting HTML. This means that Components passed to Islands in this way will simply be rendered away, meaning they'll never need to get sent to the client as code.

> Note: this feature is still pretty new and may not work well yet.

### Extensions

Extensions are core to the way Bridge works. They are simple, composable functions that hook into Bridge events.

Let's write a quick example that will simply log a message when a bridge app is generated:

```haxe
import blok.bridge.*;

function logMessage():Extension {
  return bridge -> {
    bridge.events.init.add(_ -> {
      trace('Hello world!');
    });
  }
}
```

We can now add this extension to our app:

```haxe
import blok.bridge.*;
import blok.bridge.CoreExtensions;

function main() {
  Bridge
    .start({
      version: '0.0.1',
      outputPath: 'dist/www'
    })
    .use(
      generateStaticSiteUsingDefaults(),
      // Add your new Extension here:
      logMessage()
    )
    .generate(() -> example.Example.node({}))
    .handle(result -> switch result {
      case Ok(_): trace('Done!');
      case Error(error): trace(error.message);
    });
}
```

You'll now see `Hello world!` in your console once when your app initializes.

> More coming soon.

## More Information

Coming Soon™.

Check the `example` folder for an idea of what Bridge looks like in action.
