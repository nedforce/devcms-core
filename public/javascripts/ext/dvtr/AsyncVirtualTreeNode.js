/**
 * @class Ext.dvtr.AsyncVirtualTreeNode
 * @extends Ext.tree.AsyncTreeNode
 */

Ext.dvtr.AsyncVirtualTreeNode = function(config) {
  Ext.apply(config, {
    allowDrag: false,
    allowDrop: false,
    expandable: true
  });

  this.deletable = config.userRole == "admin";
  this.year = config.extraParams.year;
  this.super_node = config.extraParams.super_node;
  this.month = config.extraParams.month;

  Ext.dvtr.AsyncVirtualTreeNode.superclass.constructor.call(this, config);

  this.constructMenu = function() {
      // Create and assign a new context menu
      this.contextMenu = new Ext.dvtr.VirtualTreeNodeContextMenu({tn: this});
  };

  this.constructMenu(true);
};

// Extend the original TreeLoader class
Ext.extend(Ext.dvtr.AsyncVirtualTreeNode, Ext.tree.AsyncTreeNode, {
  isEditable: function() {
    return false;
  },

  userHasRole: function(){
    return true;
  },

  SetContainsGlobalFrontpage: function(flag) {
    this.parentNode.SetContainsGlobalFrontpage(flag);
  },
  onContextmenu: function(node, e){
      this.contextMenu.show();
  },

  onDelete: function(){
    this.ui.addClass('x-tree-node-loading');
	var url = '/admin/nodes/' + this.super_node+'/' + this.year;
	if (!Object.isUndefined(this.month)) { url = url + '/' + this.month; }
    Ext.Ajax.request({
       url: url,
       method: 'POST', // overridden with delete by the _method parameter
       params: Ext.ux.prepareParams(this.baseParams, {_method: 'delete'}),
       scope: this,
       success: function(){
           var parent = this.parentNode;
           this.remove();
           parent.renderIndent();
           if(parent.numberChildren) { parent.renumberChildren(); }

           // Reconstruct menu as options may have changed due to a new children count, like sorting.
           parent.constructMenu();
       },
       failure: function(response, options){
          this.ui.removeClass('x-tree-node-loading');
          Ext.ux.alertResponseError(response, I18n.t('delete_failed', 'nodes'));
       }
    });
  }

  //,
  //checkChildren: function(tree, current_node, removed_node) {
  //  if (current_node.childNodes.length == 0) {
  //    current_node.remove();
  //  }
  //}

});
