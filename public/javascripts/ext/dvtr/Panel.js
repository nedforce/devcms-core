/* Ext.dvtr.Panel
 * 
 * Ext.Panel + 'beforeload' event.
 */

Ext.dvtr.Panel = Ext.extend(Ext.Panel, {
    initComponent: function () {
        Ext.dvtr.Panel.superclass.initComponent.call(this);
        this.addEvents('beforeload');
    },
    load : function () {
        if (this.fireEvent('beforeload', { panel: this }) !== false) {
            var um = this.body.getUpdater();
            um.update.apply(um, arguments);
            return this;
        }
    }
});
