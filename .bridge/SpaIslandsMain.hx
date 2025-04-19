function main() {
	var options = null;
	var adaptor = new blok.html.client.ClientAdaptor();
	{
		spa.AppHeader.hydrateIslands(adaptor, options);
		spa.AppRouter.hydrateIslands(adaptor, options);
	};
}