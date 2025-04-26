function main() {
	var options = null;
	var adaptor = new blok.html.client.ClientAdaptor();
	{
		spa.AppRouter.hydrateIslands(adaptor, options);
		spa.AppHeader.hydrateIslands(adaptor, options);
	};
}