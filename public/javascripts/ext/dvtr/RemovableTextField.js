/**
 * @class Ext.dvtr.RemovableTextField
 * @extends Ext.form.TextField
 * Regular TextField with a button for removing itself from the document.
 * @constructor
 * Creates a new RemovableTextField
 * @param {Object} config Configuration options
 */
Ext.dvtr.RemovableTextField = function (cfg) {
    Ext.dvtr.RemovableTextField.superclass.constructor.call(this, cfg);
};
Ext.extend(Ext.dvtr.RemovableTextField, Ext.form.TextField, {
    createEvent: function () {
        return {
            textField: this,
            ct: this.getContainerDom()
        };
    },
    // private
    initComponent : function () {
        Ext.dvtr.RemovableTextField.superclass.initComponent.call(this);
        this.addEvents({
            beforeremove: true,
            afterremove: true
        });
    },
    // private
    onRender: function (ct, position) {
        Ext.dvtr.RemovableTextField.superclass.onRender.call(this, ct, position);

        var btn = {
            tag: 'img',
            src: Ext.BLANK_IMAGE_URL,
            cls: 'x-removable-textfield-btn',
            id: this.id + '_remove_btn'
        };

        var btnEl = Ext.DomHelper.insertAfter(this.el.dom, btn, true);

        btnEl.on('click', function () {
            if (this.fireEvent('beforeremove', this.createEvent()) !== false) {
                this.el.next().remove(); // remove button
                this.destroy(); // remove textfield component

                this.fireEvent('afterremove', this.createEvent());
            }
        }, this);
    }
});
Ext.reg('removabletextfield', Ext.dvtr.RemovableTextField);
