document.observe('dom:loaded', function() {
  javascriptifyTreeMenus();
});

function javascriptifyTreeMenus() {
  $$('ul.treemenu_js').each(function(treemenu) {
		treemenu.childElements().each(function(treeitem) {
			treeitem.firstDescendant().observe('click', function(event) {
	      toggleTreeItem(treemenu,treeitem);
	      event.stop();
	    });
    	/*treeitem.observe('click', function(event) {
	      toggleTreeItem(treemenu,treeitem);
	      event.stop();
	    });*/
		});
  });
}

function toggleTreeItem(treemenu,treeitem) {
	plus = treeitem.firstDescendant().firstDescendant().firstDescendant().firstDescendant().firstDescendant();
	if(plus.hasClassName('tree_minus')) {
		collapse = true;
	} else {
		collapse = false;
	}
	treemenu.getElementsBySelector('li ul').each(function(item) {
		item.setStyle({'display':'none'});
	});
	treemenu.getElementsBySelector('.tree_plus').each(function(item) {
		item.removeClassName('tree_minus');
	});
	
	if(!collapse) {
		plus.addClassName('tree_minus')
		treeitem.getElementsBySelector('.branch').each(function(item) {
			item.setStyle({'display':'block'});
		});
	} else {
		plus.removeClassName('tree_minus')
		treeitem.getElementsBySelector('.branch').each(function(item) {
			item.setStyle({'display':'none'});
		});
	}
}