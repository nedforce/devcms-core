/**
 * @class Ext.dvtr.TreeLoader
 * @extends Ext.tree.TreeLoader
 */

Ext.dvtr.ContentNodeFormPanel = function (config) {
    Ext.dvtr.ContentNodeFormPanel.superclass.constructor.call(this, config);
};
// Extend the original TreeLoader class
Ext.extend(Ext.dvtr.ContentNodeFormPanel, Ext.form.FormPanel, {
    insertErrorMessages: function (error_html, modelName, title) {
        if (!title) {
            title = I18n.t('error_save_header', 'errors');
        }

        this.insert(0, {
            id: 'validation_messages_panel',
            xtype: 'panel',
            html: error_html,
            border: false,
            bodyStyle: 'margin-bottom: 10px'
        });

        Ext.each(errors, function (e) {
            if (e[0] != 'base') {
                var field = this.findById(modelName + '_' + e[0]);

                if (field) {
                    field.markInvalid(e);
                }
            }
        }, this);
    }
});
