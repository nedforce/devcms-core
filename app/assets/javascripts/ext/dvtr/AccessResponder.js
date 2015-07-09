Ext.Ajax.on('requestexception', function (conn, response, options) {
  if (response.status === 401) {
    window.location = '/admin';
    return false;
  }
});
