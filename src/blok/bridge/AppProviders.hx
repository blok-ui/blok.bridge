package blok.bridge;

import blok.Provider;
import blok.engine.*;

abstract AppProviders(Array<Providable>) from Array<Providable> to Array<Providable> {
	public function new(providers) {
		this = providers;
	}

	public function add(provider) {
		this.push(provider);
		return abstract;
	}

	public function provide() {
		return new ProviderFactory(this.map(provider -> {shared: true, value: provider}));
	}
}
