package blok.bridge;

import haxe.Json;
import blok.html.TagCollection;
import blok.ui.*;
import blok.data.*;
import blok.signal.Signal;

using StringTools;
using Reflect;

private final blokIslandTag = 'blok-island';

@:noUsing function createIslandVNode(props:{
  component:ReadonlySignal<String>,
  props:ReadonlySignal<String>,
  children:Children
}) {
  return new VRealNode(getTypeForTag(blokIslandTag), blokIslandTag, {
    style: ('display:contents':ReadonlySignal<String>),
    'data-component': props.component,
    'data-props': props.props
  }, props.children);
}

// @todo: Need something more robust than this
function propsToJson(props:{}):String {
  var out = {};
  for (name in props.fields()) {
    var value:Dynamic = props.field(name);
    if (value is SignalObject) {
      value = (value:SignalObject<Any>).peek();
    }
    if (value is Model) {
      value = value.as(Model).toJson().pipe(Json.stringify(_));
    }
    // @todo: errors if we can't handle things?
    out.setField(name, value);
  }
  return Json.stringify(out).htmlEscape(true);
}

#if !blok.server
@:noUsing function getIslandElementsForComponent(name:String) {
  return getIslandElements()
    .filter(el -> el.getAttribute('data-component') == name);
}

function getIslandProps(el:js.html.Element):{} {
  var raw = el.getAttribute('data-props') ?? '';
  return Json.parse(raw.htmlUnescape());
}

private function getIslandElements():Array<js.html.Element> {
  var items = js.Browser.document.querySelectorAll('blok-island');
  return [ for (i in 0...items.length) items.item(i).as(js.html.Element) ];
}
#else
@:noUsing function getIslandElementsForComponent(name:String) {
  return [];
}
#end