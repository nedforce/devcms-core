Ext.namespace('Ext.dvtr');

Ext.dvtr.Sorter = function (cfg) {

    // set items to 'null' explicitely if empty or not defined to fix Ext bug
    if (!cfg.items || (cfg.items instanceof Array && cfg.items.length == 0)) {
        cfg.items = null;
    }

    this.ddConfig = {};
    if (cfg.ddGroup) {
        // Add the passed in ddGroup to the config object for this sorter's DropTarget object
        this.ddConfig.ddGroup = cfg.ddGroup;
        // Add the passed in ddGroup to the defaults for all of this sorter's children
        cfg.defaults = Ext.applyIf(cfg.defaults || {}, {ddGroup: cfg.ddGroup});
        // Make sure the all sorlets know what sorter they belong to
        cfg.defaults.sorter = this;
    }

    Ext.dvtr.Sorter.superclass.constructor.call(this, cfg);
};
Ext.extend(Ext.dvtr.Sorter, Ext.Panel, {
    cls: 'x-sorter',
    initComponent : function () {
        Ext.dvtr.Sorter.superclass.initComponent.call(this);
        this.addEvents({
            validatedrop: true,
            beforedragover: true,
            dragover: true,
            beforedrop: true,
            drop: true,
            beforedestroysortlet: true,
            aftermovesortlet: true,
            afterinserttreenode: true
        });
    },

    initEvents : function () {
        Ext.dvtr.Sorter.superclass.initEvents.call(this);
        this.dd = new Ext.dvtr.Sorter.DropTarget(this, this.ddConfig);
    },

    /**
    * Returns true is a sorter is empty
    */
    isEmpty: function () {
        return !this.items || this.items.length == 0;
    },

    clear: function () {
        if (this.items != null) {
            for (var x in this.items.items) { this.remove(this.items.items[0]); }
        }
    },

    nodeIds: function () {
        if (this.items != null) {
            return this.items.items.pluck('nodeId');
        } else {
            return [];
        }
    }
});

Ext.dvtr.Sorter.DropTarget = function (sorter, cfg) {
    this.sorter = sorter;
    Ext.dvtr.Sorter.DropTarget.superclass.constructor.call(this, sorter.bwrap.dom, cfg);

    this.newSortletProxyEl = this.sorter.body.insertFirst({cls: 'x-panel-treenode-dd-spacer', style: 'display: none'});
    this.newSortletProxyEl.setVisibilityMode(Ext.Element.DISPLAY);
};

Ext.extend(Ext.dvtr.Sorter.DropTarget, Ext.dd.DropTarget, {
    createEvent : function (dd, e, data, insertIndex) {
        return {
            sorter: this.sorter,
            sortlet: data.panel,
            index: insertIndex,
            data: data,
            dd: dd,
            rawEvent: e,
            status: this.dropAllowed
        };
    },

    notifyOut: function (dd, e, data) {
        if (!(dd instanceof Ext.tree.TreeDragZone)) {
            // Save the sorter's drop target to the sortlets DDProxy
            // so it knows what sorter it was moved over the last.
            // This is used when the sortlet is dropped outside of
            // a sorter.
            dd.originatingSorterDD = this;
        } else {
            // Hide the dashed line if a tree node was dragged over
            this.newSortletProxyEl.hide();
        }
    },

    notifyOver: function (dd, e, data) {
        var xy = e.getXY();

        // Find insertion index
        var sortlet,
            match = false,
            insertIndex = 0,
            sortlets = this.sorter.items != null ? this.sorter.items.items : [];

        for (var len = sortlets.length; insertIndex < len; insertIndex++) {
            sortlet = sortlets[insertIndex];
            var h = sortlet.el.getHeight();
            if (h !== 0 && (sortlet.el.getY() + (h / 2)) > xy[1]) {
                match = true;
                break;
            }
        }

        // Fix insert index (-1 if sortlet itself was counted as well)
        this.prevPos = sortlets.indexOf(dd.panel);
        if (this.prevPos !== -1 && this.prevPos < insertIndex) { insertIndex--; }

        var event = this.createEvent(dd, e, data, insertIndex);

        if (this.sorter.fireEvent('validatedrop', event) !== false &&
            this.sorter.fireEvent('beforedragover', event) !== false) {
                if (dd instanceof Ext.tree.TreeDragZone) {
                //  If the element dragged over is a tree node:
                    if (sortlet) {
                        sortlet.el.dom.parentNode.insertBefore(this.newSortletProxyEl.dom, match ? sortlet.el.dom : null);
                    } else {
                        this.sorter.body.dom.insertBefore(this.newSortletProxyEl.dom, null);
                    }
                    this.newSortletProxyEl.show();
                } else {
                //  If the element dragged over is a sortlet:
                    proxy = dd.proxy;
                    // Move the proxy (dashed box):
                    if (sortlet) {
                        proxy.moveProxy(sortlet.el.dom.parentNode, match ? sortlet.el.dom : null);
                    } else {
                        proxy.moveProxy(this.sorter.body.dom, null);
                    }
                }
            // Save the location of the proxy, which will be used to move the actual pane on drop

            this.lastInsertIndex = match && sortlet ? insertIndex : false;
        } else {
          return "x-dd-drop-nodrop";
        }

        return event.status;
    },

    notifyDrop: function (dd, e, data) {

        var i = this.lastInsertIndex;

        // Fix insert index:         
        var correction = (this.prevPos == -1) ? 0 : 1;
        i = (i !== false) ? i : (this.sorter.items != null ? this.sorter.items.getCount() - correction : 0);

        var event = this.createEvent(dd, e, data, i);

        if (this.sorter.fireEvent('validatedrop', event) !== false &&
           this.sorter.fireEvent('beforedrop', event) !== false) {
                if (dd instanceof Ext.tree.TreeDragZone) {
                    // Hide the tree node proxy (dashed line)
                    this.newSortletProxyEl.hide();
                    // Create a new sortlet object
                    var treeNode = dd.dragData.node;
                    var insertSortlet = new Ext.dvtr.Sortlet({
                            nodeId: treeNode.id,
                            contentNodeId: treeNode.attributes.contentNodeId,
                            title: treeNode.text,
                            controllerName: treeNode.attributes.controllerName,
                            ddGroup: this.ddGroup,
                            node: treeNode,
                            hideClose: true // Close/delete can not be invoked before an id has been assigned by the server.
                    });
                    event.treeNode = treeNode;
                    event.sortlet = insertSortlet;
                } else {
                    // Move the element to its new position:
                    dd.proxy.getProxy().remove(); // remove the dashed box
                    dd.panel.el.dom.parentNode.removeChild(dd.panel.el.dom); // remove the element from its old position
                    // Insert element into new position:
                    var insertSortlet = dd.panel;
                }

                // Insert the new sortlet into the sorter
                if (this.prevPos !== -1 && this.prevPos < i) { i++; }
                this.sorter.insert(i, insertSortlet);

                // Tell the sortlet into which sorter it's been dropped, and now belongs to.
                insertSortlet.sorter = this.sorter;

                this.sorter.doLayout();

                event.sortlet = insertSortlet;

                /* invoke after-events */
                if (dd instanceof Ext.tree.TreeDragZone) {
                    this.sorter.fireEvent('afterinserttreenode', event);
                } else {
                    this.sorter.fireEvent('aftermovesortlet', event);
                }
                this.sorter.fireEvent('drop', event);
        }
    }
});
