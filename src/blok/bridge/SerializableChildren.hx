package blok.bridge;

import blok.signal.Signal;
import blok.ui.*;
#if !blok.client
import blok.html.server.*;
#end

enum abstract SerializedPrimitiveType(String) from String {
	final Element;
	final Text;
}

typedef SerializedPrimitive = {
	public final type:SerializedPrimitiveType;
	public final ?tag:Null<String>;
	public final data:Dynamic;
	public final ?children:Array<SerializedPrimitive>;
}

function fromJson(data:Array<SerializedPrimitive>):Children {
	return [for (child in data) switch child.type {
		case Text:
			blok.ui.Text.node(child.data);
		case Element:
			var props:{} = {};
			for (name in Reflect.fields(child.data)) {
				Reflect.setField(props, name, new ReadOnlySignal(Reflect.field(child.data, name)));
			}
			new VPrimitive(
				Primitive.getTypeForTag(child.tag),
				child.tag,
				props,
				fromJson(child.children)
			);
	}

	];
}

#if blok.client
function toJson(parent:View, children:Children):Array<SerializedPrimitive> {
	return [];
}
#else
function toJson(parent:View, children:Children):Array<SerializedPrimitive> {
	var adaptor = parent.getAdaptor();
	var node:blok.html.server.NodePrimitive = adaptor.createContainerNode({});
	var portal = Portal.wrap(node, () -> children).createComponent();

	portal.mount(adaptor, parent, null);

	var serialized:Array<SerializedPrimitive> = node.children.map(serializePrimitive).filter(n -> n != null);

	portal.dispose();

	return serialized;
}

function serializePrimitive(primitive:NodePrimitive):Null<SerializedPrimitive> {
	if (primitive is ElementPrimitive) {
		var el:ElementPrimitive = cast primitive;
		var attrs = @:privateAccess el.getFilteredAttributes();
		var data:haxe.DynamicAccess<Dynamic> = {};

		for (key => value in attrs) {
			data.set(key, value);
		}

		return {
			type: Element,
			tag: el.tag,
			data: data,
			children: el.children.map(serializePrimitive).filter(n -> n != null)
		};
	}

	if (primitive is TextPrimitive) {
		var el:TextPrimitive = cast primitive;
		var text = el.toString({includeTextMarkers: false});
		if (text.length == 0) return null;
		return {
			type: Text,
			data: text
		};
	}

	throw 'Unrecognized primitive: ${Type.getClassName(Type.getClass(primitive))}';
}
#end
