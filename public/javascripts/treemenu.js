document.observe('dom:loaded', function() {
  javascriptifyTreeMenus();
});

function javascriptifyTreeMenus() {
  $$('ul.treemenu_js').each(function(treemenu) {
		$$('li').each(function(treeitem) {
    	treeitem.observe('click', function(event) {
	      toggleTreeItem(treeitem);
	      event.stop();
	    });
  });
}

function toggleTreeItem(treeitem) {
	alert('toggle');
}