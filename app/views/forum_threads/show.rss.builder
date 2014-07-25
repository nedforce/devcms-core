xml << render(:partial => 'shared/feed', :locals => { :items => @replies[0..24], :content_node => @forum_topic })
