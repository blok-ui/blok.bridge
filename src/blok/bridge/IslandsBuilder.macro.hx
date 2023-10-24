package blok.bridge;

import haxe.macro.Context;
import haxe.macro.Expr;
import blok.macro.ClassBuilder;

using Lambda;
using sys.FileSystem;
using kit.Hash;
using haxe.io.Path;
using blok.macro.MacroTools;
using blok.bridge.macro.MacroTools;

function buildGeneric() {
  return switch Context.getLocalType() {
    case TInst(_, [ TInst(_.get() => {
      kind: KExpr(expr)
    }, _) ]): switch expr.expr {
      case EConst(CString(s)): 
        buildIslands([s]);
      case EArrayDecl(values):
        buildIslands(values.map(v -> v.extractString()));
      default:
        Context.error('Expected a string or an array of strings', Context.currentPos());
    }
    default:
      Context.error('Invalid number of parameters -- expects one', Context.currentPos());
      null;
  }
}

function buildIslands(packs:Array<String>) {
  var suffix = packs.join(':').hash();
  var name = 'Islands_${suffix}';
  var path:TypePath = { pack: ['blok', 'bridge', 'islands'], name: name, params: [] };
  
  if (path.typePathExists()) return TPath(path);

  var builder = new ClassBuilder([]);
  var islands = [ for (pack in packs) scanForClasses(pack, 'blok.bridge.Island') ].flatten();
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
    kind: TDClass(null, [
      {
        pack: ['blok', 'bridge'],
        name: 'IslandHydrator'
      }
    ], false, true),
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

