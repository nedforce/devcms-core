/**
 * @class Ext.dvtr.TreeLoader
 * @extends Ext.tree.TreeLoader
 */

Ext.dvtr.TreeLoader = function (config) {
  Ext.apply(config, {
    requestMethod: 'GET',
    baseParams: config.baseParams || {},
    listeners: {
      'loadexception': function (tl, node, response) {
        Ext.ux.alertResponseError(response, 'Sorry, er ging iets mis bij het openen.', false);
      },
      'load': function (tl, node) {
        // Select the active tree node, if it has been loaded by this loader:
        if (config.activeNodeId && (activeNode = node.ownerTree.getNodeById(config.activeNodeId))) {
            activeNode.select();
            //activeNode.onShow();
        }
      }
    }
  });

  Ext.dvtr.TreeLoader.superclass.constructor.call(this, config);
};
// Extend the original TreeLoader class
Ext.extend(Ext.dvtr.TreeLoader, Ext.tree.TreeLoader, {
   /**
    * Does same as overridden method, but always returns a customize AsyncTreeNode.
    */
    createNode: function (attr) {

        if (this.baseAttrs) {
            Ext.applyIf(attr, this.baseAttrs);
        }

        if (typeof attr.uiProvider == 'string') {
           attr.uiProvider = this.uiProviders[attr.uiProvider] || eval(attr.uiProvider);
        }

        attr.loader = new Ext.dvtr.TreeLoader({
          url: '/admin/' + attr.treeLoaderName,
          baseParams: this.baseParams || {}, /* inherit baseParams, note that extraParams are NOT inherited */
          activeNodeId: this.activeNodeId || null
        });

        if (attr.extraParams) {
          attr.loader.extraParams = attr.extraParams;
        }

        if (attr.id) {
          return(new Ext.dvtr.AsyncContentTreeNode(attr));
        } else {
          return(new Ext.dvtr.AsyncVirtualTreeNode(attr));
        }

    },

   /**
    * Make sure noth baseParams AND extraParams are sent.
    * baseParams are inherited through the tree, extraParams are NOT.
    */
    getParams: function (node) {
        var buf = [], bp = Ext.apply(this.extraParams || {}, this.baseParams || {});
        for (var key in bp) {
            if (typeof bp[key] != "function") {
                buf.push(encodeURIComponent(key), "=", encodeURIComponent(bp[key]), "&");
            }
        }
        buf.push("node=", encodeURIComponent(node.id));
        return buf.join("");
    }
});
