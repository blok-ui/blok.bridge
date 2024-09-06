package blog.data;

import blok.router.Link;
import blog.ui.*;
import boxup.*;

using Lambda;

class PostDecoder implements Decoder<Post> {
	public function new() {}

	public function accepts(node:Node):Bool {
		return node.type.equals(Root);
	}

	public function decode(node:Node):Result<Post, BoxupError> {
		var props = decodePostMeta(node.tryBlock('post').orReturn()).orReturn();
		var body = decodeContent(node.tryBlock('content').orReturn().children).orReturn();
		return Ok(new Post({
			title: props.title,
			slug: props.slug,
			body: body
		}));
	}

	function decodePostMeta(node:Node) {
		return Ok({
			slug: node.tryProperty('slug').orReturn(),
			title: node.tryProperty('title').orReturn(),
			published: node.tryProperty('published').map(value -> switch value {
				case 'true': true;
				default: false;
			}).or(() -> true),
			date: node.tryProperty('date').orReturn()
		});
	}

	function decodeContent(children:Array<Node>):Result<Child, BoxupError> {
		var out:Array<Child> = [];
		for (node in children) switch node.type {
			case Paragraph:
				out.push(Html.p().child(decodeContent(node.children).orReturn()));
			case Text:
				out.push(Text.node(node.textContent));
			case Block('header', _):
				out.push(Heading.node({
					children: decodeContent(node.children).orReturn()
				}));
			case Block('button', _):
				var children = decodeContent(node.children.filter(child -> switch child.type {
					case Property(_) | Parameter(_): false;
					default: true;
				})).orReturn();
				switch node.tryProperty('link') {
					case Ok(value):
						out.push(Link.node({
							url: value,
							children: children
						}));
					case Error(_):
						out.push(Button.node({
							action: e -> null,
							// label: 'todo'
							label: children
						}));
				}

			case Block(Builtin.BBold, _):
				out.push(Html.b().child(decodeContent(node.children).orReturn()));
			case Block(Builtin.BItalic, _):
				out.push(Html.i().child(decodeContent(node.children).orReturn()));
			default:
				return Error(new BoxupError('Invalid node', node.pos));
		}

		return Ok(if (out.length == 1) out[0] else Fragment.of(out));
	}
}
