Ext.namespace('Ext.dvtr');

Ext.dvtr.Sortlet = function(config){
    
    this.sorter = config.sorter;
    
    var ddConfig = {
        beforeInvalidDrop: function(dd, e, id){
            var debug = Ext.get('debug_out');
            if(!dd.sorter) {
                // If this sortlet is dropped outside of a Sorter:
                // Call notifyDrop() on the last sorter this sortlet was moved over.
                this.originatingSorterDD.notifyDrop(this, e, {});
            }
        }
    };
    if(config.ddGroup) { ddConfig.ddGroup = config.ddGroup; }
    
    // create some portlet tools using built in Ext tool ids
    var tools = [{
        id:'toggle',
        scope: this,
        hidden: true,
        handler: function(e, target, sortlet){
            this.toggleCollapse(true);
        }
     },{
        id:'close',
        scope: this,
        hidden: (config.hideClose == undefined) ? false : config.hideClose,
        handler: function(e, target, sortlet){
            var event = {
                sortlet: this,
                sorter: this.sorter
            };
            if(this.sorter.fireEvent('beforedestroysortlet', event)) {
               sortlet.ownerCt.remove(sortlet, true);
            }
        }
    }];
    
    Ext.applyIf(config, {
        draggable: ddConfig,
        cls: 'x-sortlet',
        frame: false,
        collapsed: true,
        tools: tools
    });
    Ext.dvtr.Sortlet.superclass.constructor.call(this, config);

};
Ext.extend(Ext.dvtr.Sortlet, Ext.Panel, {
    assignId: function(id){
        this.id = id;
        this.tools.close.show();
    },
    showCollapse: function(){
        this.tools.toggle.show();
    },
    showSpinner: function(){
        this.header.addClass('x-sortlet-header-loading');
    },
    hideSpinner: function(){
        this.header.removeClass('x-sortlet-header-loading');
    }
});

Ext.reg('sortlet', Ext.dvtr.Sortlet);
