package blok.bridge;

import blok.ui.*;

#if blok.server
import blok.bridge.server.BridgeMiddleware;
#end

enum AppNameStrategy {
  Skip;
  Custom(path:String);
  FromCompiler(?name:String);
}

enum HydrationStrategy {
  Skip;
  Collect(id:String);
  IslandsOnly;
}

typedef BridgeOptions = {
  public final ?rootId:String;
  public final ?appNameStrategy:AppNameStrategy;
  public final ?hydrationStrategy:HydrationStrategy;
}

class Bridge {
  final endpoints:Array<ApiBase>;
  final render:(bridge:Bridge)->Child;
  final options:BridgeOptions;

  public function new(endpoints, render, options:BridgeOptions) {
    this.endpoints = endpoints;
    this.render = render;
    this.options = options;
  }

  public function mount():Task<Document> {
    // @todo
    return null;
  }

  #if blok.server
  public function createMiddleware():BridgeMiddleware {
    return new BridgeMiddleware(this);
  }
  #end

  function makeApisCurrent() {
    for (api in endpoints) api.makeCurrent();
  }
}
