/**
 * @class Ext.dvtr.VirtualTreeNodeContextMenu
 * @extends Ext.menu.Menu
 */

Ext.dvtr.VirtualTreeNodeContextMenu = function (config) {
    if (!config || !config.tn || !(config.tn instanceof Ext.dvtr.AsyncVirtualTreeNode)) {
        throw new SyntaxError('Ext.dvtr.VirtualTreeNodeContextMenu requires an Ext.dvtr.AsyncVirtualTreeNode instance to be set to the \'tn\' config option.');
    }
    // Call superclass' constructor:
    Ext.dvtr.VirtualTreeNodeContextMenu.superclass.constructor.call(this, config);

    this.tn = config.tn;

    // Add the 'Verwijderen' menu item:
    if (this.tn.deletable) {
        this.add({
            text: 'Verwijderen',
            icon: '/images/icons/delete.png',
            scope: this,
            handler: function () {
                Ext.Msg.show({
                    title: I18n.t('delete_content', 'nodes'),
                    msg: I18n.t('delete_all_items', 'nodes'),
                    buttons: Ext.Msg.YESNO,
                    scope: this,
                    fn: function (btn) {
                        if (btn == 'yes') {
                            this.tn.onDelete();
                        }
                    },
                    icon: Ext.MessageBox.QUESTION
                });
            }
        });
    }
};

// Extend the Menu class
Ext.extend(Ext.dvtr.VirtualTreeNodeContextMenu, Ext.menu.Menu, {
    show: function () {
        if (this.items.getCount() > 0) {
            Ext.dvtr.VirtualTreeNodeContextMenu.superclass.show.call(this, this.tn.ui.getAnchor());
        }
    }
});
