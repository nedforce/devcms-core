/*
* @class Ext.dvtr.NodeDropField
* @extends Ext.form.TextField
*
* Implements a form field component that receives tree nodes when dragged in.
* The the tree node's id is then automatically set the input field. Its text
* is displayed to the right of the field.
*
* @args
*   cfg - Config object with options for the node drop field.
*
* @cfg
*   text    - Initial text to be displayed to the right of the field. (String)
*   ddGroup - DD group name of the TreePanel of which this node drop
*             field may receive tree nodes. (String)
*/

Ext.dvtr.NodeDropField = function (cfg) {
    this.originalText = cfg.text || '';
    this.ddConfig = {ddGroup: cfg.ddGroup};
    Ext.applyIf(cfg, {width: 30, readOnly: true});
    Ext.dvtr.NodeDropField.superclass.constructor.call(this, cfg);
};
Ext.extend(Ext.dvtr.NodeDropField, Ext.form.TextField, {
    cls: 'x-node-drop-field',
    initComponent : function () {
        Ext.dvtr.NodeDropField.superclass.initComponent.call(this);
        this.addEvents({
            validatedrop: true,
            beforedragover: true,
            dragover: true,
            beforedrop: true,
            drop: true,
            afterinserttreenode: true
        });
        this.on('validatedrop', function (e) {
            if (e.dd.dragData.node != null && e.nodeDropField.allowedContentTypes != null) {
                return e.nodeDropField.allowedContentTypes.indexOf(e.dd.dragData.node.attributes.ownContentType) != -1
            }
            return true;
        })
    },

    initEvents : function () {
        Ext.dvtr.NodeDropField.superclass.initEvents.call(this);
        this.dd = new Ext.dvtr.NodeDropField.DropTarget(this, this.ddConfig);
    },

    setText : function (txt) {
        this.textLabel.update(txt);
    },

    setImage : function (url) {
        this.textLabel.update('<img src="'+url+'"/>')
    },

    onRender: function (ct, position) {
        Ext.dvtr.NodeDropField.superclass.onRender.call(this, ct, position);

        var span = {
            tag: 'span',
            cls: 'x-node-drop-field-txt',
            id: this.id + '_txt',
            html: this.originalText
        };

        var clear = {
            tag: 'a',
            cls: 'x-node-drop-field-clear',
            id: this.id + '_clear',
            html: '&times;'
        };

        this.clearLink = Ext.DomHelper.insertAfter(this.el.dom, clear, true);
        this.textLabel = Ext.DomHelper.insertAfter(this.el.dom, span, true);

        this.clearLink.on('click', function () {
          this.setRawValue('');
          this.setText('');
          this.clearLink.addClass('hidden')
        }, this);

        if(this.value == '') this.clearLink.addClass('hidden')
    }
});

Ext.dvtr.NodeDropField.DropTarget = function (ndf, cfg) {
    this.nodeDropField = ndf;
    // this.on('validatedrop', this.validateDrop);
    Ext.dvtr.NodeDropField.DropTarget.superclass.constructor.call(this, ndf.el.dom, cfg);
};

Ext.extend(Ext.dvtr.NodeDropField.DropTarget, Ext.dd.DropTarget, {
    createEvent : function (dd, e, data) {
        return {
            nodeDropField: this.nodeDropField,
            data: data,
            dd: dd,
            rawEvent: e,
            status: this.dropAllowed
        };
    },

    notifyOut: function (dd, e, data) {
        this.nodeDropField.el.removeClass('x-node-drop-field-over');
    },

    notifyOver: function (dd, e, data) {

        var event = this.createEvent(dd, e, data);

        if (this.nodeDropField.fireEvent('validatedrop', event) !== false &&
            this.nodeDropField.fireEvent('beforedragover', event) !== false &&
            dd instanceof Ext.tree.TreeDragZone) {

              this.nodeDropField.el.addClass('x-node-drop-field-over');
        }

        return event.status;
    },

    notifyDrop: function (dd, e, data) {

        var event = this.createEvent(dd, e, data);

        if (this.nodeDropField.fireEvent('validatedrop', event) !== false &&
            this.nodeDropField.fireEvent('beforedrop', event) !== false &&
            dd instanceof Ext.tree.TreeDragZone) {

            // Create a new sortlet object
            var treeNode = dd.dragData.node;
            // set the node ide
            this.nodeDropField.setRawValue(treeNode.id);

            // Set text or image
            if (treeNode.ownContentType == 'Image') {
                this.nodeDropField.setImage('/'+treeNode.URLAlias+'/newsletter_banner.jpg');
            } else {
                this.nodeDropField.setText(treeNode.text);
            }

            this.nodeDropField.el.removeClass('x-node-drop-field-over');

            if(this.nodeDropField.getRawValue() == '') this.nodeDropField.clearLink.addClass('hidden')
            else this.nodeDropField.clearLink.removeClass('hidden')
        }
    }
});
