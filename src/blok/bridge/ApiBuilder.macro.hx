package blok.bridge;

import blok.macro.ClassBuilder;
import haxe.http.HttpMethod;
import haxe.macro.Context;
import haxe.macro.Expr;

using Lambda;
using blok.bridge.macro.MacroTools;
using blok.bridge.routing.UrlTools;
using blok.macro.MacroTools;
using kit.Hash;

function buildGeneric() {
  return switch Context.getLocalType() {
    case TInst(_, [
      TInst(_.get() => {kind: KExpr(macro $v{(url:String)})}, _)
    ]):
      buildApi(url.normalizeUrl());
    default:
      throw 'assert';
  }
}

function build(rootUrl:String) {

}

typedef ApiFieldEndpoint = {
  public final url:String;
  public final method:HttpMethod;
  public final match:Case;
} 

private function parseEndpoint(field:Field):ApiFieldEndpoint {
  return switch field.kind {
    case FFun(func):
      var info = switch field.meta.find(f -> f.name == ':endpoint')?.params {
        case [ { expr: EConst(CIdent(method)), pos: pos } ]:
          validateMethod(method, pos);
          { method: method, url: null };
        case [ { expr: EConst(CIdent(method)), pos: pos }, { expr: EConst(CString(url)) } ]:
          validateMethod(method, pos);
          { method: method, url: url };
        default:
          field.pos.error('Invalid arguments for :endpoint');
          null;
      }

      var caseExpr:Case = {
        values: [],
        guard: switch info.method {
          case 'Post': macro request.method == Post;
          default: macro request.method == Get;
        },
        expr: macro null
      }

      null;
    default:
      field.pos.error(':endpoint fields can only be used on methods');
      null;
  }
}

private function validateMethod(value:String, pos:Position) {
  switch value {
    case 'Get' | 'Post':
    default: pos.error('Expected Get or Post');
  }
}

private function buildApi(url:String) {
  var suffix = url.hash();
  var name = 'Api_${suffix}';
  var path:TypePath = { 
    pack: [ 'blok', 'bridge', 'api' ], 
    name: name, 
    params: [] 
  };

  if (path.typePathExists()) return TPath(path);

  Context.defineType({
    pack: path.pack,
    name: path.name,
    meta: [
      {
        name: ':autoBuild',
        params: [ macro blok.bridge.ApiBuilder.build($v{url}) ],
        pos: (macro null).pos
      }
    ],
    kind: TDClass(null, [
      {
        pack: [ 'blok', 'bridge' ],
        name: 'ApiBase'
      }
    ], true),
    fields: [],
    pos: (macro null).pos
  });

  return TPath(path);
}
