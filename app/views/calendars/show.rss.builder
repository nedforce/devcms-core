xml << render(:partial => 'shared/feed', :locals => { :items => @calendar_items, :content_node => @calendar })
