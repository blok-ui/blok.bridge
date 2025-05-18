package blog.modifier;

import blok.html.Html.ElementNode;
import blok.signal.Signal.ReadOnlySignal;

function style<Attrs:{}>(node:ElementNode<Attrs>, style:ReadOnlySignal<ClassName>) {
	return node.attr(ClassName, style);
}
