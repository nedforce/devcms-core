/**
 * Ext.ux.RemoteCheckboxGroup & Ext.ux.RemoteRadioGroup
 *
 * @author  lei101206 http://extjs.com/forum/member.php?u=33662
 * @updates Alejandro López alelopez@gmail.com
 * @version 2009-03-16
 * @date    16. March 2009
 * @forExt  2.2.1
 *
 * @license Ext.ux.RemoteCheckboxGroup & Ext.ux.RemoteRadioGroup are licensed
 * under the terms of the Open Source LGPL 3.0 license.  Commercial use is
 * permitted to the extent that the code/component(s) do NOT become part of
 * another Open Source or Commercially licensed development library or toolkit
 * without explicit permission.
 *
 * License details: http://www.gnu.org/licenses/lgpl.html
 */

Ext.namespace("Ext.ux");

/**
 * @class Ext.ux.RemoteCheckboxGroup
 * @extends Ext.form.CheckboxGroup
 * @constructor
 */
Ext.ux.RemoteCheckboxGroup = Ext.extend(Ext.form.CheckboxGroup,
{
  /**
   * @cfg {Object} baseParams.
   * An object containing properties which are used as parameters on the HTTP request.
   * @property
   */
  baseParams: null,
  /**
   * @cfg {String} url.
   * The URL from which to load data through an HttpProxy.
   */
  url: '',
  /**
   * @cfg {Array} defaultItems.
   * A list of config items to be displayed as default, when resulst are empty or an exception occurs
   */
  defaultItems:
  [
    {
      boxLabel: I18n.t('no_items_found','ext'),
      disabled: true
    }
  ],
  /**
   * @cfg {String} itemCls.
   * CSS class to apply to each item
   */
  itemCls: '',
  /**
   * @cfg {String} fieldId.
   * Name of the field (as it is in the fields config of the reader) to set the id property of the items
   */
  fieldId: 'id',
  /**
   * @cfg {String} fieldName.
   * Name of the field (as it is in the fields config of the reader) to set the name property of the items
   */
  fieldName: 'name',
  /**
   * @cfg {String} fieldLabel.
   * Name of the field (as it is in the fields config of the reader) to set the boxLabel property of the items
   */
  fieldLabel: 'boxLabel',
  /**
   * @cfg {String} fieldValue.
   * Name of the field (as it is in the fields config of the reader) to set the inputValue property of the items
   */
  fieldValue: 'inputValue',
  /**
   * @cfg {String} fieldChecked.
   * Name of the field (as it is in the fields config of the reader) to set the checked property of the items
   */
  fieldChecked: 'checked',
  /**
   * @cfg {@link Ext.data.JsonReader} reader.
   * JsonReader object for reading the records from the HTTP request
   */
  reader: null,
  /**
   * @cfg {Number} maxItems.
   * Max ammount of items to show.
   * Set to 0 or false to disable this limit.
   */
  maxItems: 100,

	initComponent: function()
  {
    Ext.ux.RemoteCheckboxGroup.superclass.initComponent.call(this);
    this.addEvents(
    /**
     * @event loadexception
     * Fires when an error occurs while loading the items.
     * @param {Ext.form.Field} this
     * @param {Object} error object
     */
    'loadexception');
  },

  onRender: function(H, F)
  {
    this.items = this.defaultItems;

    if ((this.url != '') && (this.reader != null))
    {
      try
      {
        var conn = Ext.lib.Ajax.getConnectionObject().conn;
        conn.open("GET", this.url, false);
        conn.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');

        conn.send(Ext.urlEncode(this.baseParams) || null);

        var response = Ext.decode(conn.responseText);

        if (response.success)
        {
          var data = this.reader.readRecords(Ext.decode(conn.responseText));
          var item;
          var record;
          var checked;

          if (data.records.length > 0)
          {
            this.items = [];
          }

          for (var i = 0; (i < data.records.length) && (!this.maxItems || (i < this.maxItems)); i++)
          {
            record = data.records[i];
            item =
            {
              boxLabel: record.get(this.cbFieldLabel),
              inputValue: record.get(this.cbFieldValue),
              cls: this.itemCls
            }

            if (this.cbFieldId != '')
            {
              item.id = record.get(this.cbFieldId);
            }

            if (this.cbFieldName != '')
            {
              item.name = this.cbFieldName;
            }

            if (this.cbFieldChecked != '')
            {
              item.checked = record.get(this.cbFieldChecked);
            }

            this.items.push(item);
          }
        }
      }
      catch (err)
      {
        this.fireEvent("loadexception", this, err);
        this.items = this.defaultItems;
      }
    }
    Ext.ux.RemoteCheckboxGroup.superclass.onRender.call(this, H, F)
  }
});
Ext.reg("remotecheckboxgroup", Ext.ux.RemoteCheckboxGroup);

