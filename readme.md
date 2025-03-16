# Blok Bridge

Tools for making Blok apps that run on the server and the client.

> Note: This project is in heavy development and could change completely at any time.

## Usage

At the moment, Bridge provides a way to create a static website with islands of interactivity, all using the same codebase. It was heavily influenced by React Server Components (in concept if not in implementation).

In the future it might also be possible to use Bridge with server-side rendering, but that's beyond the scope of the current project.

## Overview

### Setting Things Up

Bridge apps start with simple configuration. Here's a minimal example:

```haxe
import blok.bridge.*;

function main() {
  Bridge
    .start({
      version: '0.0.1',
      outputPath: 'dist/www',
      target: Server(8080)
    })
    .run(() -> example.Example.node({}));
}
```

The entrypoint of our Bridge app is just a normal Component (called "Example" in this case):

```haxe
package example;

import blok.*;
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

We're going to run a dev server in node for now, although Bridge also supports a PHP target:

```hxml
-cp src

-lib blok.bridge
-lib kit.file
-lib hxnodejs

-main Run

-js dist/run
-cmd node dist/run
```

This will build a client-side app and setup a simple server you can visit at `http://localhost:8080`.

> Note that the server support Bridge provides is still highly experimental, limited and not for production. Generate a static site (more on that later) for production apps instead.

### Adding Routes

Bridge uses the Blok Router package to handle routes. It will automatically follow any links created using the `blok.router.Link` component and output static HTML for each. Here's what our app looks like with some routes:

```haxe
package example;

import blok.html.Html;
import blok.Child;
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

If you compile your app again you should be able to visit `/counter/1` and `/counter/2`.

This is starting to become useful, but still isn't much more exciting than just creating those HTML files yourself. Let's add a little interactivity.

### Islands

An `Island` is almost exactly like a standard Blok component, but it has a little extra magic that allows it to work on both the client and the server. Let's create a Counter component for our counter route:

```haxe
package example;

import blok.bridge.*;
import blok.*;
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
import blok.Child;
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
import blok.*;
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
import blok.*;
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

When you compile the app again, this should just work! If you take a peek at the html in your browser console, you'll see that the children in the `label` attribute have been serialized to a very simple JSON representation. Importantly, however, there is no sign of the `Label` component -- Bridge has pre-rendered it and _only_ sent the resulting HTML. This means that Components passed to Islands in this way will simply be rendered away, meaning they'll never need to get sent to the client as code.

> Note: this feature is still pretty new and may not work well yet.

## More Information

Coming Soon™.

Check the `example` folder for an idea of what Bridge looks like in action.
