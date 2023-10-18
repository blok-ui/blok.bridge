package blok.ui;

import blok.macro.ClassBuilder;
import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.Tools;
using blok.macro.MacroTools;

function build() {
  var builder = ClassBuilder.fromContext();
  var cls = Context.getLocalClass().get();
  var params = cls.params.toTypeParamDecl();

  if (cls.superClass == null || !Context.unify(TInst(cls.superClass.t, []), (macro:blok.ui.Component).toType())) {
    cls.pos.error('Must extend blok.ui.Component to use blok.ui.Island');
  }

  var module = Context.getLocalModule().split('.');
  var name = module[module.length - 1] == cls.name
    ? module.join('.')
    : module.concat([cls.name]).join('.');

  // @todo: We need to investigate props somehow and make sure they
  // are serializable.
  
  var fields = macro class {
    public static function island(props) {
      // @todo: Throw error if not in server context?
      var child = node(props);
      var json = blok.ui.IslandTools.propsToJson(props);
      return blok.ui.IslandTools.createIslandVNode({
        component: $v{name},
        props: json,
        children: child
      });
    }
  }

  // @todo: we need toJson and fromJson methods. 

  builder.addField(fields
    .getField('island')
    .unwrap()
    .applyParameters(params)
  );

  builder.add(macro class {
    #if !blok.server
    public static function hydrateIslands(adaptor:blok.adaptor.Adaptor) {
      var elements = blok.ui.IslandTools.getIslandElementsForComponent($v{name});
      return [ for (el in elements) {
        var props:Dynamic = blok.ui.IslandTools.getIslandProps(el);
        var comp = node(props).createComponent();
        // @todo: this is a bit awkward, but it works...
        // ... but *should* we have some sort of Root component set up by the
        // Islands class? How do we handle Context? Think on this.
        @:privateAccess comp.__adaptor = adaptor;
        var cursor = adaptor.createCursor(el.firstChild);
        // @todo: Context is gonna be tricky.
        comp.hydrate(cursor, null, null);
        comp;
      } ];
    }
    #end
  });

  return builder.export();
}
