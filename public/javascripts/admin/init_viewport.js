initViewport = function(pnl) {
  
  Ext.Ajax.timeout = 120000;
  // If you pass in a Component instead of a config object you'll have to set the margins manually!
  Ext.apply(pnl, { region: 'center', margins: '0 5 5 5' })

  new Ext.Viewport({
          layout: 'border',
          items: [{
              region: 'north',
              contentEl: 'header',
              margins: '5 5 5 5'
          }, {
              region: 'center',
              layout: 'border',
              border: false,
              items: [{
                  region: 'north',
                  contentEl: 'menu',
                  margins: '0 5 5 5'
              }, pnl]
          }]
  });
}