/**
 * @class Ext.dvtr.RemovableFieldSet
 * @extends Ext.form.FieldSet
 * Regular FieldSet with a button for removing itself from the document.
 * @constructor
 * Creates a new RemovableFieldSet
 * @param {Object} config Configuration options
 */

Ext.dvtr.RemovableFieldSet = function (cfg) {
    Ext.apply(cfg, {
        autoHeight: true,
        labelPad: 10,
        cls: 'removable',
        labelWidth: 140,
        width: 550,
        border: false
    });

    Ext.dvtr.RemovableFieldSet.superclass.constructor.call(this, cfg);
};

Ext.extend(Ext.dvtr.RemovableFieldSet, Ext.form.FieldSet, {
    // private
    onRender: function (ct, position) {
        Ext.dvtr.RemovableFieldSet.superclass.onRender.call(this, ct, position);

        var btn = {
            tag: 'img',
            src: Ext.BLANK_IMAGE_URL,
            cls: 'x-removable-fieldset-btn',
            id: this.id + '_remove_btn'
        };

        var btnEl = Ext.DomHelper.insertAfter(this.el.dom, btn, true);

        btnEl.on('click', function () {
            var fieldSetsWrapper = this.ownerCt.ownerCt;
            fieldSetsWrapper.remove(this.ownerCt);
            fieldSetsWrapper.doLayout();
        }, this);
    }
});

Ext.reg('removablefieldset', Ext.dvtr.RemovableFieldSet);
