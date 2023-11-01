package blok.bridge;

import blok.html.TagCollection;
import blok.signal.Signal;
import blok.ui.*;

using Reflect;
using StringTools;

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

#if !blok.server
@:noUsing function getIslandElementsForComponent(name:String) {
  var items = js.Browser.document.querySelectorAll('blok-island[data-component="$name"]');
  return [ for (i in 0...items.length) items.item(i).as(js.html.Element) ];
}

function getIslandProps(el:js.html.Element):{} {
  var raw = el.getAttribute('data-props') ?? '';
  return haxe.Json.parse(raw.htmlUnescape());
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
