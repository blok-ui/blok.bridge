package blok.bridge.server;

import blok.html.server.*;

using Lambda;
using Reflect;

class ServerDocument extends Document {
  final head = new Element('head', {});
  final body = new Element('body', {});

  public function getHead():Dynamic {
    return cast head;
  }

  public function getBody():Dynamic {
    return cast body;
  }

  public function getLayer(name:String):Dynamic {
    var layer = body.children.find(obj -> obj.field('attributes').field('id') == name);
    if (layer == null) {
      layer = new Element('div', { id: name });
      body.prepend(layer);
    }
    return cast layer;
  }

  public function toString():String {
    return '<!doctype html>
<html>
  ${head.toString()}
  ${body.toString()}
</html>';
  }
}
