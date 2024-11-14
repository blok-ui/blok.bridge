# Partials

Instead of loading a new page every time we click a link, we should introduce Partials, a very HTMX-like feature.

Basically, everything inside a Partial gets rendered as an HTML fragment. On static sites this will be saved in its own folder using some to-be-determined naming convention. It will also work as a normal Island, outputting the required code for hydration in its spot in the generated html.

On the client, the Partial will hydrate all the islands inside itself on initial render and keep track of them. When the user clicks on an appropriate link (probably some kind of SwapLink island?) the Partial will cancel all active islands, display a `loading` state, fetch the requested partial, set the innerHtml of the primitive it controls (*not* hydrate it), and the run `hydrateIslands` on the new HTML.

There are a lot of complicated things to consider here, but it could be a cool thing to have in the future.

Also! We'd make a Partial the default root of all applications, which is how we'd handle initial page hydration.

## Notional API:

```haxe
// This creates a PartialContext, so all children of a Partial know what target
// they should swap.
Partial.wrap(() -> {
  // The current body of the partial:
  Html.div()
    // A Partial link will swap the current Partial wrapper with the 
    // contents of the given link:
    .child(Partial.link(Foo.createUrl({bar: 'bar'})).child('Click this'));
});
```

In order to work, the link will also need to have a Partial wrapper. For example, this is what our Foo route would look like:

```haxe
class Foo extends RouteComponent<'/foo/{bar:String}'> {
  function render():Child {
    return Html.view(<html>
      <head>
        <title>'Foo ' bar</title>
      </head>
      <body>
        <SiteHeader />
        // Only the contents of the wrapped partial will be sent if this is a 
        // partial request!
        <Partial>
          <p>'Bar is currently: ' bar</p>
          <PartialLink to={Home.createUrl()}>'Return home'</PartialLink>
        </Partial>
      </body>
    </html>);
  }
}
```

Really, the way you want to do this is create a layout with a shared partial and then use that in any page which will use the partial feature. This way you can keep code that will never change -- like a site header -- outside of the partial, and only swap the parts that need swapping.

As for implementation: for static sites, every route will now output the normal, full html, but will also output html fragments (probably in a `partials` subfolder) for any partials it encounters.

## Implementation Ideas

It might make the most sense to have the Partial provide a `blok.router.Navigator` and a `blok.router.RouteVisitor` that override the default ones. This could mean that we don't need a `PartialLink` -- instead, normal `Link` components will simply get intercepted by `Partials`, making this a very easy feature to implement.
