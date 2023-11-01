package blok.bridge;

import blok.ui.ComponentBuilder.builderFactory;
import blok.macro.*;
import blok.macro.builder.*;
import haxe.macro.Context;

function build() {
  return builderFactory.withBuilders(
    new JsonSerializerBuilder({
      constructorAccessor: macro node,
      returnType: macro:blok.ui.Child
    }),
    new IslandComponentBuilder()
  ).fromContext().export();
}

class IslandComponentBuilder implements Builder {
  public final priority:BuilderPriority = Late;

  public function new() {}

  public function apply(builder:ClassBuilder) {
    var cls = builder.getClass();
    var module = Context.getLocalModule().split('.');
    var islandType = module[module.length - 1] == cls.name
      ? module.join('.')
      : module.concat([cls.name]).join('.');

    builder.add(macro class {
      public static final islandType = $v{islandType};
      
      #if !blok.server
      public static function hydrateIslands(parent:blok.ui.ComponentBase) {
        var elements = blok.bridge.IslandTools.getIslandElementsForComponent(islandType);
        return [ for (el in elements) {
          var props:{} = blok.bridge.IslandTools.getIslandProps(el);
          var comp = fromJson(props).createComponent();
          var cursor = parent.getAdaptor().createCursor(el.firstChild);
          // @todo: Context is gonna be tricky.
          comp.hydrate(cursor, parent, null);
          comp;
        } ];
      }
      #end
      
      function __islandName() {
        return islandType;
      }
    });
  }
}
