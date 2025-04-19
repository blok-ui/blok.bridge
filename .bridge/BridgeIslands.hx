function main() {
	var options = null;
	var adaptor = new blok.html.client.ClientAdaptor();
	{
		blog.ui.Dropdown.hydrateIslands(adaptor, options);
		blog.ui.Collapse.hydrateIslands(adaptor, options);
		blog.island.Counter.hydrateIslands(adaptor, options);
	};
}