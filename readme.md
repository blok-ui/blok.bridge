# Blok Bridge

Tools for making Blok apps that run on the server and the client.

> Note: This project is in heavy development and could change completely at any time.

## Usage

At the moment, Bridge provides a way to create a static website with islands of interactivity, all using the same codebase. It was heavily influenced by React Server Components (in concept if not in implementation).

In the future it might also be possible to use Bridge with server-side rendering, but that's beyond the scope of the current project.

## Overview

### Setting Things Up

> Note: I'm still investigating ways to make setting up a Bridge project easier. There are some benefits to using the Hotdish build system, but it's unavoidably a bit awkward. 

Behind the scenes, Bridge apps are not straightforward to compile. It needs to run (or compile) the server-side Haxe code, generate the HTML for all the pages in your site, gather any Islands it encountered during rendering, and then generate the client-side code to hydrate those islands. This is in addition to handling any other assets the user may have added, like CSS and images, and placing them in the right place.

To make handling all of this a little easier, Bridge uses a library called [Hotdish](https://github.com/wartman/hotdish). This gives you a single place to handle configuration using a composable api similar to Blok's components. First, set up a `project.hxml` file (or whatever you want to name it) that looks like this:

```hxml
-cp ./

-lib hotdish
-lib blok.bridge

--run Project
```

Then create a `Project.hx` in the same root directory:

```haxe
import blok.bridge.*;
import blok.bridge.hotdish.*;
import hotdish.*;
import hotdish.node.*;

function main() { 
  var project = new Project({
    name: 'example',
    version: new SemVer(0, 0, 1),
    url: '',
    contributors: ['wartman'],
    license: 'MIT',
    description: 'Some example app',
    releasenote: 'Some note about this release',
    children: [
      new Build({
        sources: ['src'],
        children: [
          new BlokBridge({
            bootstrap: 'example.Example',
            version: '0.0.1',
            server: new BuildServer({
              children: [
                new Hxml({ name: 'build-app' }),
                new HaxeLib({}),
                new Run({})
              ]
            })
          })
        ]
      })
    ]
  });
  project.run();
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

If you run `$ haxe project.hx`, you should see a few things happen: first, Hotdish will generate `haxelib.json` and `build-app.hxml` files for you (due to the `Hxml` and `HaxeLib` nodes added in the `Project.hx` file). For code completion, you should now point your IDE at `build-app.hxml`, not at `project.hxml`. Next, it will have generated a few files in a folder called `artifacts` (these are the main functions for the client and server and a json manifest that will list all the Islands your app uses, if there are any) and -- finally -- it will have output `dist/public/index.html` with the HTML we generated in our `start` method. 

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

> Note: Bridge doesn't have anything like a development server yet, so the DX here is not the best. For now, I've been using the `serve` package from npm to host the `dist/public` folder (but any similar solution should work). This does require you to reload the page every time you make a change -- no cool hot-module-reloading here -- but it works. This is a place I want to improve, but it's lower down on the priority list.

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
          <fallback>{_ -> "Not found"}</fallback>
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

## More Information

Coming Soon™.

Check the `example` folder for an idea of what Bridge looks like in action.
