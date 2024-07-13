package blog.data;

import blog.ui.Heading;
import blok.signal.Signal;

using Markdown;
using StringTools;

abstract PostContent(Child) from Child to Child {
	public static function fromJson(data:String):PostContent {
		return markdownToBlok(data).orThrow();
	}

	public function new(child) {
		this = child;
	}

	public function toJson():String {
		return '';
	}

	public function unwrap():Child {
		return this;
	}
}

function markdownToBlok(content:String):Result<Child> {
	var html = try content.markdownToHtml() catch (e) {
		return Error(new Error(InternalError, e.message));
	}
	var root = Xml.parse(html);
	return xmlToBlok(root);
}

// @todo: Should this be in its own package maybe?
private function xmlToBlok(node:Xml):Result<Child> {
	return switch node.nodeType {
		case Document:
			Ok(Fragment.of([for (child in node) switch xmlToBlok(child) {
				case Ok(child): child;
				case Error(error): return Error(error);
			}]));
		case PCData if (node.nodeValue == '\n' || node.nodeValue.trim() == ''):
			Ok(Placeholder.node());
		case PCData:
			Ok(Text.node(node.nodeValue));
		case Element if (node.nodeName == 'script'):
			Ok(Placeholder.node());
		case Element:
			var attrs:Map<String, String> = [];
			var name = node.nodeName;
			var children:Children = [for (child in node) switch xmlToBlok(child) {
				case Ok(child): child;
				case Error(error): return Error(error);
			}];

			for (attr in node.attributes()) attrs.set(attr, node.get(attr));

			switch name {
				case 'h1': return Ok(Heading.node({children: children}));
				default:
			}

			if (allowedHtmlTags.contains(name)) {
				var type = Primitive.getTypeForTag(name);
				var props:{} = {};
				for (name => value in attrs) {
					Reflect.setField(props, name, new ReadOnlySignal(value));
				}
				return Ok(new VPrimitive(type, name, props, children));
			}

			Error(new Error(NotFound, 'Cannot render <${node.nodeName}>.'));
		default:
			Ok(Placeholder.node());
	}
}

private final allowedHtmlTags = [
	'div',
	'code',
	'aside',
	'article',
	'blockquote',
	'section',
	'header',
	'footer',
	'main',
	'nav',
	'table',
	'thead',
	'tbody',
	'tfoot',
	'tr',
	'td',
	'th',
	'h1',
	'h2',
	'h3',
	'h4',
	'h5',
	'h6',
	'strong',
	'em',
	'span',
	'a',
	'p',
	'ins',
	'del',
	'i',
	'b',
	'small',
	'menu',
	'ul',
	'ol',
	'li',
	'label',
	'button',
	'pre',
	'picture',
	'canvas',
	'audio',
	'video',
	'form',
	'fieldset',
	'legend',
	'select',
	'option',
	'dl',
	'dt',
	'dd',
	'details',
	'summary',
	'figure',
	'figcaption',
	'textarea',
	'br',
	'embed',
	'hr',
	'img',
	'input',
	'link',
	'meta',
	'param',
	'source',
	'track',
	'wbr',
];
