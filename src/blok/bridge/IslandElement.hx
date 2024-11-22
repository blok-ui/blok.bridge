package blok.bridge;

import blok.signal.Signal;
import blok.ui.*;
import haxe.Json;

using Reflect;
using StringTools;

class IslandElement extends Component {
	public static inline extern final tag:String = 'blok-island';

	#if blok.client
	@:noUsing public static function getIslandElementsForComponent(name:String, ?options:{
		?root:js.html.Element
	}) {
		var root:js.html.Element = options?.root ?? cast js.Browser.document;
		var items = root.querySelectorAll('$tag[data-component="$name"]');
		return [for (i in 0...items.length) items.item(i).as(js.html.Element)];
	}

	public static function getIslandProps(el:js.html.Element):{} {
		var raw = el.getAttribute('data-props') ?? '';
		return haxe.Json.parse(raw.htmlUnescape());
	}

	static function getIslandElements():Array<js.html.Element> {
		var items = js.Browser.document.querySelectorAll(tag);
		return [for (i in 0...items.length) items.item(i).as(js.html.Element)];
	}
	#else
	@:noUsing public static function getIslandElementsForComponent(name:String, ?options:{
		?root:Dynamic
	}) {
		return [];
	}
	#end

	@:attribute final component:String;
	@:attribute final props:{};
	@:children @:attribute final child:Child;

	function render():Child {
		#if blok.client
		return child;
		#else
		return new VPrimitiveView(
			PrimitiveView.getTypeForTag(tag),
			tag,
			{
				'data-component': Signal.ofValue(component),
				'data-props': Signal.ofValue(Json.stringify(props).htmlEscape(true)),
				'style': Signal.ofValue('display:contents')
			},
			[child]
		);
		#end
	}
}
