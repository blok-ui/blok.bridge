package blok.bridge.server;

import kit.http.Middleware;

abstract MiddlewareStack(Array<Middleware>) {
	public inline function new(mw) {
		this = mw;
	}

	public inline function add(mw:Middleware) {
		this.push(mw);
		return abstract;
	}

	@:to public inline function unwrap():Array<Middleware> {
		return this;
	}
}
