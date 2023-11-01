Blok Bridge
===========

Server-only functions for Blok.

Usage
-----

Apis are just normal Blok Contexts. They can be used as resources:

```haxe
class SomeComponent extends Component {
  @:resource final foo:Foo = FooApi.from(this).getFoo(1);

  // etc.
}
```

> @todo: More on this once things stabilize.

Islands
-------

> Note: this is mostly speculative for now.

Islands must be used inside an `Archipelago` component (that's me being cute with naming). On the server, the `Archipelago` is just a standard component that renders its children. On the client, the `Archipelago` will instead load all the `IslandComponents` it can find in the given packages and hydrate them. This ensures that those components will still have access to any parent contexts.

```haxe
function main() {
  // Depending on the mode, `Bridge.mount` will create static
  // HTML, mount to the DOM, or mount to an empty node to allow 
  // the Archipelago to hydrate the registered Islands.
  Bridge.mount([
    new FooApi()
  ], _ -> Archipelago.wrap(
    // A list of packages to scan for Islands.
    [my.islands, other.islands],
    // The child to render on the server. Note: `wrap` is a macro,
    // so this code will simply be removed on the client side.
    Html.div({}, 
      my.islands.SomeIsland.node({ foo: 'bar' })
    )
  ));
}
```
