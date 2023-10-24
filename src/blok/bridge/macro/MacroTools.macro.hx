package blok.bridge.macro;

import haxe.macro.Expr;
import haxe.macro.Context;

using blok.macro.MacroTools;

@:noUsing function isServer() {
  return Context.defined('blok.server');
}

function extractString(expr:Expr):String {
  return switch expr.expr {
    case EConst(CString(s)): 
      s;
    default: 
      expr.pos.error('Expected a string');
      '';
  }
}
