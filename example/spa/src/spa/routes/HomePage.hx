package spa.routes;

import blok.*;
import blok.html.Html;
import blok.router.Page;
import spa.ui.*;

class HomePage extends Page<'/'> {
	@:signal final swap:Bool = false;
	@:computed final message:String = if (swap()) "Hello World" else "Foo";

	function render():Child {
		return Html.view(<PageLayout name="Home">
			<div>
				<p>message</p>
				<button onClick={_ -> swap.update(swap -> !swap)}>"Click"</button>
			</div>
		</PageLayout>);
	}
}
