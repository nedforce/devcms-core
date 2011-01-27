/**
* Defines several helper functions on the Ext.ux namespace.
*
* =NOTE=
* All ActiveRecord error message related functions are *DEPRECATED*.
* Most forms now make use of Rails' default +error_messages_for+ method,
* except those of poll questions.
*/

Ext.ux = {
   /* Ext.ux.prepareParams(o1, o2)
    *
    * Merges two objects with request parameters and encodes them.
    */
    prepareParams: function(defaultParams, customParams){
        return Ext.urlEncode(Ext.applyIf(customParams, defaultParams))
    },

   /**
    * Shows a message centered in the right panel's body element.
    * Optionally pass in the window object of which the right panel is part,
    * if calling from a different window.
    */
    showRightPanelMssg: function(mssg, win){
        var win = win || window // Use current window if none is given
        win.Ext.get('right_panel_body').update(
            "<div class='rightPanelDefault'><table><tr><td>"+mssg+"</td></tr></table></div>"
        );
    },

   /**
    * Shows a popup displaying error messages. Tries to extract one or more error messages
    * from the response text if it is JSON. (looks for 'error' and 'errors' attributes of the JSON object)
    * Shows the complete response text if no error message can be found.
    * Also updates the right panel with the message, unless the +updateRightPanel+ argument is set to false.
    */
    alertResponseError: function(responseObj, mssg, updateRightPanel) {
        var error = mssg || 'Sorry, er is een fout opgetreden.<br\/><br\/>'
        var explanation
        try{
          var responseJson = Ext.util.JSON.decode(responseObj.responseText)
          explanation = responseJson.error || responseJson.errors.join("\n")
        }catch(e){
          explanation = responseObj.responseText
        }
        Ext.Msg.alert('Foutmelding', error + ' <br/> <br/>' + '"' + Ext.util.Format.htmlEncode(Ext.util.Format.ellipsis(explanation, 3000)) + '"')

        if(updateRightPanel)
            rightPanel.body.update('<div class="flash error">'+error + explanation+'<\/div>')
    },

    renderDate: function(value) {
        return Ext.util.Format.date(Date.parse(value), 'd-m-Y');
    }
};

Ext.override(Array, {
    includes: function(el){
        return (this.indexOf(el) != -1)
    },
    join: function(sep){
        var str = ""
        Ext.each(this, function(e){
            str += (e + sep)
        })
        return str.substr(0, str.length - sep.length)
    }
});

Ext.override(Ext.form.Field, {
    getContainerDom: function(){
        return this.getEl().up('.x-form-item')
    },
    showContainer: function() {
        this.enable();
        this.show();
        this.getContainerDom().setDisplayed(true); // show entire container and children (including label if applicable)
    },

    hideContainer: function() {
        this.disable(); // for validation
        this.hide();
        this.getContainerDom().setDisplayed(false); // hide container and children (including label if applicable)
    },

    setContainerVisible: function(visible) {
        if (visible) {
            this.showContainer();
        } else {
            this.hideContainer();
        }
        return this;
    }
});

// [OPEN-518][3.x/2.x] Bug in radiogroup when using brackets in name : http://www.extjs.com/forum/showthread.php?p=210602
Ext.DomQuery.matchers[2] = {
    re: /^(?:([\[\{])(?:@)?([\w-]+)\s?(?:(=|.=)\s?(["']?)(.*?)\4)?[\]\}])/,
    select: 'n = byAttribute(n, "{2}", "{5}", "{3}", "{1}");'
};

Ext.override(Ext.form.Radio, {
    getGroupValue : function(){
        var c = this.getParent().child('input[name="'+this.el.dom.name+'"]:checked', true);
        return c ? c.value : null;
    },
    toggleValue : function() {
        if(!this.checked){
            var els = this.getParent().select('input[name="'+this.el.dom.name+'"]');
            els.each(function(el){
                if(el.dom.id == this.id){
                    this.setValue(true);
                }else{
                    Ext.getCmp(el.dom.id).setValue(false);
                }
            }, this);
        }
    },
    setValue : function(v){
        if(typeof v=='boolean') {
            Ext.form.Radio.superclass.setValue.call(this, v);
        }else{
            var r = this.getParent().child('input[name="'+this.el.dom.name+'"][value="'+v+'"]', true);
            if(r && !r.checked){
                Ext.getCmp(r.id).toggleValue();
            };
        }
    }
});

// [FIXED-405][3.??] this.id.indexOf is not a function : http://www.extjs.com/forum/showthread.php?t=89069
Ext.override( Ext.Component, {
     getStateId : function(){
        return this.stateId || ((/^(ext-comp-|ext-gen)/).test(String(this.id)) ? null : this.id);
    }
});

