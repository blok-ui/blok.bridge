package blok.ui;

import haxe.macro.Context;
import haxe.macro.Expr;
import blok.macro.ClassBuilder;

using sys.FileSystem;
using kit.Hash;
using haxe.io.Path;
using blok.macro.MacroTools;

function buildGeneric() {
  return switch Context.getLocalType() {
    case TInst(_, [ TInst(_.get() => {kind: KExpr(macro $v{(pack:String)})}, _) ]):
      buildIslands(pack);
    default:
      Context.error('Invalid number of parameters -- expects one', Context.currentPos());
      null;
  }
}

function buildIslands(pack:String) {
  var suffix = pack.hash();
  var name = 'Islands_${suffix}';
  var path:TypePath = { pack: ['blok', 'ui', 'islands'], name: name, params: [] };
  
  if (path.typePathExists()) return TPath(path);

  var builder = new ClassBuilder([]);
  var islands = scanForClasses(pack, 'blok.ui.Island');
  var hydration:Array<Expr> = [ for (island in islands) {
    var path = island.pack.concat([ island.name, island.sub ].filter(n -> n != null));
    macro $p{path}.hydrateIslands(adaptor);
  } ];

  builder.add(macro class {
    final adaptor = new blok.html.client.ClientAdaptor();

    public function new() {}

    public function hydrate() {
      var components = Lambda.flatten([ $a{hydration} ]);
      return components;
    }
  });

  Context.defineType({
    pack: path.pack,
    name: path.name,
    pos: (macro null).pos,
    kind: TDClass(null, null, false, true),
    fields: builder.export()
  });

  return TPath(path);
}

private function scanForClasses(pack:String, implementing:String):Array<TypePath> {
  var types:Array<TypePath> = [];
  var roots = Context.getClassPath();
  var packParts = pack.split('.');

  for (root in roots) {
    var dir = root.normalize();
    if (dir.exists()) {
      types = types.concat(scanForClassInDir(dir, packParts, implementing));
    }
  }

  return types;
}

private function scanForClassInDir(root:String, pack:Array<String>, implementing:String):Array<TypePath> {
  var types:Array<TypePath> = [];
  var dir = Path.join([ root ].concat(pack));

  if (!dir.exists()) return types;

  for (file in dir.readDirectory()) if (file.extension() == 'hx') {
    var name = file.withoutExtension();
    var type = Context.getType(pack.concat([ name ]).join('.'));
    if (Context.unify(type, Context.getType(implementing))) {
      types.push({
        pack: pack,
        name: name
      });
    }
  }
  
  return types;
}

