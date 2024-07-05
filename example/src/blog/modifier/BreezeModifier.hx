package blog.modifier;

import blok.html.VHtmlPrimitive;
import blok.signal.Signal.ReadOnlySignal;

function style(primitive:VHtmlPrimitive, style:ReadOnlySignal<ClassName>) {
	return primitive.attr(ClassName, style);
}
