xml << render(:partial => 'shared/feed', :locals => {:items => @weblog_posts, :content_node => @weblog})
