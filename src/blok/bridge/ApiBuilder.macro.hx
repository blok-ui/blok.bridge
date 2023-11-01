package blok.bridge;

import blok.macro.*;
import blok.context.ContextBuilder;
import haxe.macro.Context;
import haxe.macro.Expr;

using Lambda;
using StringTools;
using blok.bridge.macro.MacroTools;
using blok.bridge.routing.UrlTools;
using blok.macro.MacroTools;
using haxe.io.Path;
using haxe.macro.Tools;
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
  return new ClassBuilderFactory([
    new ContextBuilder(),
    new ApiBuilder(rootUrl)
  ]).fromContext().export();
}

class ApiBuilder implements Builder {
  public final priority:BuilderPriority = Normal;
  final rootUrl:String;

  public function new(rootUrl) {
    this.rootUrl = rootUrl;
  }

  public function apply(builder:ClassBuilder) {
    var ct = builder.getComplexType();
    
    // for (field in builder.findFieldsByMeta(':endpoint')) {
    //   createMethodProxy(builder, field);
    // }

    if (Context.defined('blok.server')) {
      applyServer(builder);
    } else {
      applyClient(builder);
    }

    switch builder.findField('dispose') {
      case Some(_):
      case None:
        builder.add(macro class {
          public function dispose() {}
        });
    }
  }

  // function createMethodProxy(builder:ClassBuilder, field:Field) {
  //   var name = field.name;
  //   var hiddenName = '__$name';

  //   field.name = hiddenName;

  //   var args = switch field.kind {
  //     case FFun(f): f.args;
  //     default: [];
  //   }
  //   var callArgs = args.map(a -> macro $i{a.name});

  //   builder.addField({
  //     name: name,
  //     access: [ APublic, AStatic ],
  //     pos: (macro null).pos,
  //     kind: FFun({
  //       args: args,
  //       expr: macro return getCurrent().$hiddenName($a{callArgs})
  //     })
  //   });
  // }

  function applyClient(builder:ClassBuilder) {
    for (field in builder.findFieldsByMeta(':endpoint')) {
      parseClientEndpoint(field);
    }
  }

  function applyServer(builder:ClassBuilder) {
    var endpoints = [ for (field in builder.findFieldsByMeta(':endpoint')) {
      parseServerEndpoint(field);
    } ];

    builder.add(macro class {
      public function match(request:kit.http.Request):kit.Maybe<kit.Future<kit.http.Response>> {
        @:mergeBlock $b{endpoints};
        return None;
      }
    });
  }

  function extractEndpointInfo(field:Field) {
    var name = field.name;
    
    // if (name.startsWith('__')) {
    //   name = name.substr(2);
    // }

    return switch field.getMetadata(':endpoint')?.params {
      case [ { expr: EConst(CIdent(method)), pos: pos } ]:
        validateMethod(method, pos);
        { method: method, url: Path.join([ rootUrl, name.toKebabCase() ]) };
      case [ { expr: EConst(CIdent(method)), pos: pos }, { expr: EConst(CString(url)) } ]:
        validateMethod(method, pos);
        { method: method, url: Path.join([ rootUrl, url ]) };
      default:
        field.pos.error('Invalid arguments for :endpoint');
        null;
    }
  }

  function parseClientEndpoint(field:Field):Void {
    switch field.kind {
      case FFun(func):
        var name = field.name;
        var info = extractEndpointInfo(field);
        var decoder:Expr = switch func.ret.toType().follow().toComplexType() {
          case macro:kit.Task<$t, $_>: switch t {
            case macro:String:
              macro __data.data;
            case t if (t.isModel()):
              var path = switch t {
                case TPath(p): p.typePathToArray();
                default: throw 'assert';
              }
              macro $p{path}.fromJson(__data);
            default:
              field.pos.error(':endpoint methods must return a kit.Task that contains a blok.data.Model or a String.');
              macro null;
          }
          case t:
            trace(t.toString());
            field.pos.error(':endpoint methods must return a kit.Task');
            macro null;
        }
        
        switch info.method {
          case 'Get':
            var params = [ for (arg in func.args) switch arg.type {
              case macro:String: macro $i{arg.name};
              case t if (t.isModel()):
                field.pos.error('The argument ${arg.name} cannot be a blok.data.Model on a Get endpoint. Only Post endpoints can use Models.');
                macro null;
              default: macro Std.string($i{arg.name});
            } ];
            var url = if (params.length > 0) {
              macro [ $v{info.url} ].concat([ $a{params} ]).join('/');
            } else {
              macro $v{info.url};
            }
            func.expr = macro {
              var request = new kit.http.Request(Get, $url, [
                new kit.http.HeaderField(Accept, 'application/json')
              ]);
              return blok.bridge.client.Fetch.fetch(request).next(__data -> $decoder);
            }
          default:
            var data:Array<ObjectField> = [ for (arg in func.args) switch arg.type {
              case macro:String: { field: arg.name, expr: macro $i{arg.name} };
              case t if (t.isModel()): { field: arg.name, expr: macro haxe.Json.stringify($i{arg.name}.toJson()) };
              default: { field: arg.name, expr :macro Std.string($i{arg.name}) };
            } ];
            var payload:Expr = {
              expr: EObjectDecl(data),
              pos: (macro null).pos
            };
            var url = macro $v{info.url};
            func.expr = macro {
              var request = new kit.http.Request(Post, $url, [
                new kit.http.HeaderField(ContentType, 'application/json'),
                new kit.http.HeaderField(Accept, 'application/json')
              ], haxe.io.Bytes.ofString(haxe.Json.stringify($payload)));
              return blok.bridge.client.Fetch.fetch(request).next(__data -> $decoder);
            }
        }
      default:
        field.pos.error(':endpoint fields can only be used on methods');
    }
  }

  // @todo: This is a mess, but we figured out how to make it work.
  function parseServerEndpoint(field:Field):Expr {
    return switch field.kind {
      case FFun(func):
        var name = field.name;
        var matcherName = '__matcher_$name';
        var info = extractEndpointInfo(field);
        var params = [ for (index => arg in func.args) switch info.method {
          case 'Get':
            var matcher = switch arg.type {
              case macro:String: '[a-zA-Z0-9\\-_]';
              case macro:Int: '\\d';
              case t if (t.isModel()):
                field.pos.error('The argument ${arg.name} cannot be a blok.data.Model on a Get endpoint. Only Post endpoints can use Models.');
              default:
                field.pos.error('The arguments ${arg.name} must be a String or an Int for Get endpoints');
            }
            var extractor = switch arg.type {
              case macro:Int: macro Std.parseInt($i{matcherName}.matched($v{index}));
              default: macro $i{matcherName}.matched($v{index});
            }
            { 
              matcher: '(' + matcher + (arg.opt == true ? '*' : '+') + ')',
              extractor: extractor
            };
          default:
            var extractor = switch arg.type {
              case macro:String: macro Reflect.field(__data, $v{arg.name});
              case macro:Int: macro $i{matcherName}.matched(Reflect.field(__data, $v{arg.name}));
              case t if (t.isModel()):
                var path = switch t {
                  case TPath(p): p.typePathToArray();
                  default: throw 'assert';
                }
                macro $p{path}.fromJson(Reflect.field(__data, $v{arg.name}));
              default:
                field.pos.error('Invalid type for the argument ${arg.name}');
                macro null;
            }
            { 
              matcher: '', 
              extractor: extractor
            };
        }];
        var extractors = params.map(p -> p.extractor);
        var matcherRegExp = '^' + (switch info.method {
          case 'Get' if (params.length > 0):
            info.url + '/' + params.map(p -> p.matcher).join('/');
          default: info.url; 
        }) + '$';
        var call:Expr = macro @:pos(field.pos) this.$name($a{extractors});
        var expr:Expr = switch func.ret.toType().follow().toComplexType() {
          case macro:kit.Task<$t, $_>: switch t {
            case macro:String:
              macro Some(blok.bridge.routing.ResponseTools.toResponse($call.map(s -> haxe.Json.stringify({ data: s }))));
            case t if (t.isModel()):
              macro Some(blok.bridge.routing.ResponseTools.toResponse($call.map(s -> haxe.Json.stringify(s.toJson()))));
            default:
              field.pos.error(':endpoint methods must return a kit.Task that contains a blok.data.Model or a String.');
              macro null;
          }
          case t:
            trace(t.toString());
            field.pos.error(':endpoint methods must return a kit.Task');
            macro null;
        }
        
        return switch info.method {
          case 'Get': macro {
            static final $matcherName = new EReg($v{matcherRegExp}, '');
            if (request.method == Get && $i{matcherName}.match(request.url)) return $expr;
          }
          default: macro {
            static final $matcherName = new EReg($v{matcherRegExp}, '');
            if (request.method == Post && $i{matcherName}.match(request.url)) {
              switch blok.bridge.routing.RequestTools.getJsonPayload(request) {
                case Some(__data): return $expr;
                case None:
              }
            }
          }
        }
      default:
        field.pos.error(':endpoint fields can only be used on methods');
        null;
    }
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
