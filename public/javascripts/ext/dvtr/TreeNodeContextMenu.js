/**
 * @class Ext.dvtr.TreeNodeContextMenu
 * @extends Ext.menu.Menu
 */

Ext.dvtr.TreeNodeContextMenu = function (config) {
    if (!config || !config.tn || !(config.tn instanceof Ext.dvtr.AsyncContentTreeNode)) {
        throw new SyntaxError('Ext.dvtr.TreeNodeContextMenu requires an Ext.dvtr.AsyncContentTreeNode instance to be set to the \'tn\' config option.');
    }
    // Call superclass' constructor:
    Ext.dvtr.TreeNodeContextMenu.superclass.constructor.call(this, config);

    this.tn = config.tn;

    this.add({
        text: '<b>' + I18n.t('show', 'generic') + '</b>',
        scope: this.tn,
        handler: this.tn.onShow
    });

    if (this.tn.attributes.creatableChildContentTypes.length > 0 ||
        this.tn.attributes.allowEdit ||
        !this.tn.undeletable) {
      this.add('-'); // separator if more menu items are to be added.
    }

    // Add the 'Toevoegen' menu item:
    if (this.tn.attributes.creatableChildContentTypes.length > 0) {
        this.add({
            text: I18n.t('add', 'generic'),
            icon: '/images/icons/add.png',
            menu: {
                defaults: {
                    scope: this.tn,
                    handler: this.tn.onInsertNew
                },
                items: this.tn.attributes.creatableChildContentTypes
            }
        });
    }

    if (this.tn.attributes.hasImport) {
        this.add({
            text: I18n.t('import_items', 'nodes'),
            icon: '/images/icons/add.png',
            scope: this.tn,
            handler: this.tn.onImport
        });
    }

    // Add the 'Bewerken' menu item:
    if (this.tn.attributes.allowEdit) {
        this.add({
            text: I18n.t('edit', 'generic'),
            icon: '/images/icons/pencil.png',
            scope: this.tn,
            handler: this.tn.onEdit
        });
    }

    // Link to item edit
    if (this.tn.attributes.hasEditItems) {
        this.add({
            text: I18n.t('edit_items', this.tn.ownContentType),
            icon: '/images/icons/pencil.png',
            scope: this.tn,
            handler: this.tn.onEditItems
        });
    }

    // Add sync settings menu item
    if (this.tn.attributes.hasSync) {
        this.add({
            text: I18n.t('sync', 'nodes'),
            icon: '/images/icons/arrow_switch.png',
            scope: this.tn,
            handler: this.tn.onSync
        });
    }

    // Add the 'Verwijderen' menu item:
    if (!this.tn.undeletable) {
        this.add({
            text: I18n.t('delete', 'generic'),
            icon: '/images/icons/delete.png',
            scope: this,
            handler: function () {
              if (this.tn.isRepeatingCalendarItem) {
                Ext.Msg.show({
                  title: I18n.t('repeating_calendar_delete_title', 'calendar_items'),
                  msg: I18n.t('repeating_calendar_delete_message', 'calendar_items'),
                  buttons: Ext.Msg.YESNOCANCEL,
                  scope: this,
                  fn: function (btn) {
                    if (btn == 'yes') {
                      this.tn.onRepeatingCalendarItemDelete();
                    } else if (btn == 'no') {
                      this.tn.onDelete();
                    }
                  },
                  icon: Ext.MessageBox.QUESTION
                });
              } else {
               Ext.Msg.show({
                 title: I18n.t('delete_content', 'generic'),
                 msg: ((this.tn.isFrontpage) ? I18n.t('delete_frontpage_node', 'nodes') : I18n.t('delete_node', 'nodes')),
                 buttons: Ext.Msg.YESNO,
                 scope: this,
                 fn: function (btn) { if (btn == 'yes') { this.tn.onDelete(); }},
                 icon: Ext.MessageBox.QUESTION
               });
              }
            },
            disabled: this.tn.isGlobalFrontpage || this.tn.isRoot || this.tn.containsGlobalFrontpage
        });
    }

    // Add the 'Bewerken' menu item:
    if (this.tn.userRole == 'admin' && this.tn.attributes.ownContentType == 'Site') {
		this.add('-'); //separator

        this.add({
              text: I18n.t('show', 'abbreviations'),
              icon: '/images/icons/table_lightning.png',
              scope: this.tn,
              handler: this.tn.onAbbreviations
        });

		this.add({
              text: I18n.t('show', 'synonyms'),
              icon: '/images/icons/table_relationship.png',
              scope: this.tn,
              handler: this.tn.onSynonyms
        });
    }

    if (this.tn.allowLayoutConfig || this.tn.allowGlobalFrontpageSetting || this.tn.allowContentCopyCreation ||
        this.tn.allowUrlAliasSetting || this.tn.allowSortChildren) {

      this.add('-'); // separator

      if (this.tn.allowSortChildren) {
          this.sortItem = this.add({
            text: I18n.t('sort_content', 'context_menu'),
            menu: new Ext.menu.Menu({
                items: [
                    itemForSortMenu(I18n.t('sort_by_title', 'nodes'), 'title', this.tn),
                    itemForSortMenu(I18n.t('sort_by_created_at', 'nodes'), 'date', this.tn)
                ]
            })
          });
          var cnt = this.tn.childCountChanged ? this.tn.childNodes.length : this.tn.initialChildCount;
          if (cnt < 2) {
              this.sortItem.disable();
          }
      }

      if (this.tn.allowLayoutConfig) {
        this.add({
            text: I18n.t('layout_settings', 'context_menu'),
            scope: this.tn,
            handler: this.tn.onLayoutConfig
        });
      }

      // Add the 'Maak globale frontpage' item
      if (this.tn.allowGlobalFrontpageSetting) {
          this.add({
              text: I18n.t('make_global', 'context_menu'),
              scope: this.tn,
              handler: this.tn.onSetGlobalFrontpage,
              disabled: this.tn.isGlobalFrontpage || this.tn.isPrivate || this.tn.hasPrivateAncestor
          });
      }

      // Add the 'Maak kopie' item
      if (this.tn.allowContentCopyCreation) {
          this.add({
              text: I18n.t('make_copy', 'context_menu'),
              scope: this.tn,
              handler: this.tn.onCreateContentCopy
          });
      }

      // Add the 'Webadres...' item
      if (this.tn.allowUrlAliasSetting) {
        this.add({
          text: I18n.t('url_alias', 'context_menu'),
          scope: this.tn,
          handler: this.tn.onSetUrlAlias
        });
      }
    }

    // Add the 'Rol toewijzen' menu item:
    if (this.tn.userRole == 'admin' && this.tn.allowRoleAssignment) {
      this.add('-'); // separator

      this.add({
        text: I18n.t('assign_role', 'context_menu'),
        scope: this.tn,
        handler: this.tn.onAssignRole
      });
    }

    this.add('-'); // separator

    if (this.tn.allowToggleHidden && !this.tn.hasHiddenAncestor) {
      // Add the 'Verborgen' property setting
      this.add({
        xtype: 'checkitem',
        text: I18n.t('hidden', 'context_menu'),
        checked: this.tn.isHidden,
        scope: this.tn,
        checkHandler: this.tn.onToggleHidden,
        disabled: this.tn.isGlobalFrontpage || this.tn.containsGlobalFrontpage
      });
    }

    if (this.tn.allowTogglePrivate && !this.tn.hasPrivateAncestor) {
      // Add the 'Prive' property setting
      this.add({
        xtype: 'checkitem',
        text: I18n.t('private', 'context_menu'),
        checked: this.tn.isPrivate,
        scope: this.tn,
        checkHandler: this.tn.onTogglePrivate,
        disabled: this.tn.isGlobalFrontpage || this.tn.containsGlobalFrontpage
      });
    }

    // Add the 'Toon in menu' property setting
    if (this.tn.allowShowInMenu && (!this.tn.isRoot && !(this.tn.isPrivate || this.tn.hasPrivateAncestor))) {
      this.add({
        xtype: 'checkitem',
        text: I18n.t('show_in_menu', 'context_menu'),
        checked:  this.tn.attributes.showInMenu,
        scope: this.tn,
        checkHandler: this.tn.onToggleShowInMenu
      });
    }

    // Add the 'Heeft feed' property setting
    this.add({
        xtype: 'checkitem',
        text: I18n.t('has_own_feed', 'context_menu'),
        checked: this.tn.attributes.hasChangedFeed,
        scope: this.tn,
        checkHandler: this.tn.onToggleHasChangedFeed,
        disabled: this.tn.allowToggleChangedFeed
    });
};

// Extend the Menu class
Ext.extend(Ext.dvtr.TreeNodeContextMenu, Ext.menu.Menu, {
    show: function () {
        if (this.items.getCount() > 0) {
            Ext.dvtr.TreeNodeContextMenu.superclass.show.call(this, this.tn.ui.getAnchor());
        }
    }
});

function itemForSortMenu(text, sortBy, tn) {
  var ascDescItems = [
      {text: I18n.t('sort_ascending', 'nodes'), icon: '/images/icons/sort_asc.gif', order: 'asc'},
      {text: I18n.t('sort_descending', 'nodes'), icon: '/images/icons/sort_desc.gif', order: 'desc'}
  ];
  return {
      text: text,
      menu: new Ext.menu.Menu({
        defaults: {
           handler: function (orderItem) {
              tn.onSort(sortBy, orderItem.order);
           }
        },
        items: ascDescItems
      })
  };
}
