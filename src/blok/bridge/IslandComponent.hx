package blok.bridge;

import blok.adaptor.*;
import blok.debug.Debug;
import blok.diffing.Differ;
import blok.signal.Graph;
import blok.ui.*;

// @todo: We're repeating a *lot* of what blok.ui.Component does here
// to make things work. What's a better option? Is there a more elegant way
// we can author our Components?
@:autoBuild(blok.bridge.IslandComponentBuilder.build())
abstract class IslandComponent extends ComponentBase {  
  var __child:Null<ComponentBase> = null;

  abstract function setup():Void;
  abstract function render():Child;
  abstract function toJson():Dynamic;
  abstract function __islandName():String;
  abstract function __updateProps():Void;

  function __render():VNode {
    // @todo: we wrap our render method in a Scope as this
    // component is not actually reactive. This is a problem
    // with Blok: we should come up with a more elegant
    // way to handle this.
    var child = Scope.wrap(_ -> render());
    #if blok.server
    switch findAncestorOfType(IslandComponent) {
      case None:
        return IslandTools.createIslandVNode({
          component: __islandName(),
          props: StringTools.htmlEscape(haxe.Json.stringify(toJson()), true),
          children: child
        });
      case Some(_):
        // We don't want to wrap nested Islands! Only top-level
        // IslandComponents will need hydration.
    }
    #end
    return child;
  }

  function __initialize() {
    __child = __render().createComponent();
    __child?.mount(this, __slot);
    withOwner(this, setup);
  }

  function __hydrate(cursor:Cursor) {
    __child = __render().createComponent();
    __child?.hydrate(cursor, this, __slot);
    withOwner(this, setup);
  }

  function __update() {
    __updateProps();
    __child = updateChild(this, __child, __render(), __slot);
  }

  function __validate() {
    __child = updateChild(this, __child, __render(), __slot);
  }

  function __dispose() {}

  function __updateSlot(oldSlot:Null<Slot>, newSlot:Null<Slot>) {
    __child?.updateSlot(newSlot);
  }

  public function getRealNode():Dynamic {
    var node = __child?.getRealNode();
    assert(node != null, 'Component does not have a node');
    return node;
  }

  public function visitChildren(visitor:(child:ComponentBase) -> Bool) {
    if (__child != null) visitor(__child);
  }
}
