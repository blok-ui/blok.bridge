package blok.bridge;

import haxe.macro.Context;
import haxe.macro.Expr;

using Lambda;
using haxe.io.Path;
using sys.io.File;
using sys.FileSystem;

function createWrapper(packages:Expr, child:Expr):Expr {
  var packs = exprToPackageNames(packages);
  var islands = buildIslands(packs);
  return macro blok.ui.Scope.wrap(context -> {
    #if !blok.server
    $islands;
    return null;
    #else
    return $child;
    #end
  });
}

typedef IslandPackage = {
  public final pack:Array<String>;
  public final pos:Position;
}

function exprToPackageNames(expr:Expr):Array<IslandPackage> {
  return switch expr.expr {
    case EConst(CIdent(_)) | EField(_, _):
      [exprToPackage(expr)];
    case EArrayDecl(paths):
      paths.map(exprToPackageNames).flatten();
    default: 
      Context.error('Invalid expression', expr.pos);
  }
}

function exprToPackage(expr:Expr):IslandPackage {
  return switch expr.expr {
    case EConst(CIdent(s)): 
      {
        pack: [s],
        pos: expr.pos
      };
    case EField(exprB, name):
      var pack = exprToPackage(exprB).pack.concat([ name ]);
      return {
        pack: pack,
        pos: expr.pos
      };
    default: 
      Context.error('Invalid expression', expr.pos);
  }
}

function buildIslands(packs:Array<IslandPackage>) {
  var islands = [ for (pack in packs) scanForClasses(pack, 'blok.bridge.IslandComponent') ].flatten();
  var hydration:Array<Expr> = [ for (island in islands) {
    var path = island.pack.concat([ island.name, island.sub ].filter(n -> n != null));
    macro $p{path}.hydrateIslands(context);
  } ];

  return macro $b{hydration};
}

private function scanForClasses(pack:IslandPackage, implementing:String):Array<TypePath> {
  var types:Array<TypePath> = [];
  var roots = Context.getClassPath();

  for (root in roots) {
    var dir = root.normalize();
    if (dir.exists()) {
      types = types.concat(scanForClassInDir(dir, pack, implementing));
    }
  }

  if (types.length == 0) {
    Context.error('The package ${pack.pack.join('.')} does not exist or does not contain islands', pack.pos);
  }

  return types;
}

private function scanForClassInDir(root:String, pack:IslandPackage, implementing:String):Array<TypePath> {
  var types:Array<TypePath> = [];
  var dir = Path.join([ root ].concat(pack.pack));

  if (!dir.exists()) return types;

  for (file in dir.readDirectory()) if (file.extension() == 'hx') {
    var name = file.withoutExtension();
    var type = Context.getType(pack.pack.concat([ name ]).join('.'));
    if (Context.unify(type, Context.getType(implementing))) {
      types.push({
        pack: pack.pack,
        name: name
      });
    }
  }
  
  return types;
}
