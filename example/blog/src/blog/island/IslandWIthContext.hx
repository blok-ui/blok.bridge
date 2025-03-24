package blog.island;

import blog.context.BlogConfig;
import blok.bridge.Island;

class IslandWIthContext extends Island {
	@:signal final showName:Bool = true;
	@:context final config:BlogConfig;

	function render():Child {
		return Html.view(<div>
			<button onClick={_ -> showName.update(show -> !show)}>"Toggle"</button>
			<div>
				<Show condition=showName>{() -> <h1>{config.name}</h1>}</Show>
			</div>	
		</div>);
	}
}
