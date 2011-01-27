RTF_CNT = 0; // number of inserted removable textfields
  
/*
* Returns number of removable textfields in #poll_question_options.
*/
nrOfOptions = function(){
     return Ext.get('poll_question_options').select('.formFieldCt').getCount();
};

/*
* Inserts a new removable textfield in #poll_question_options.
* Textfield's id defaults to 'new_option_{nr}'.
* Textfield's name defaults to 'poll_question[new_poll_option_attributes][][text]'.
*
* Arguments
* cfg: Config object containing optional id and name for textfield (e.g. {id: str, name: str}).
*/
insertOption = function(cfg){
    cfg = cfg || {};
    // Init default config options
    Ext.applyIf(cfg,{
        id: 'new_option_'+RTF_CNT,
        name: 'poll_question[new_poll_option_attributes][][text]',
        value: ''
    });

    // Create container
    var ct = Ext.DomHelper.append('poll_question_options', {tag: 'div', cls: 'formFieldCt'}, true);
    // Insert label
    Ext.DomHelper.append(ct, {tag: 'label', html: I18n.t('answer_option', 'poll_options'), 'for': cfg.id});

    // Insert textfield
    new Ext.dvtr.RemovableTextField({
        id: cfg.id,
        name: cfg.name,
        width: 250,
        value: cfg.value,
        renderTo: ct,
        listeners: {
            beforeremove: function(e){
                if( nrOfOptions() > 2 ){
                    e.textField.el.up('.formFieldCt').remove(); // remove containing element (including label)
                } else {
                    Ext.Msg.alert('Sorry', I18n.t('minimal_two', 'poll_options'))
                }
                return false; // to suppress default behaviour
            }
        }
    });

    RTF_CNT++; // Increase total count
};
