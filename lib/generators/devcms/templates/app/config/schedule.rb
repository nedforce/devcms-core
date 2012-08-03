set :output, nil

every :day do
  rake 'db:remove_unverified_users'
end

every 1.day, :at => '9am' do
  runner 'NewsletterEditionMailerWorker.new.send_newsletter_editions'
end

every 1.day, :at => '5pm' do
  runner 'NewsletterEditionMailerWorker.new.send_newsletter_editions'
end  

every 1.day, :at => '4:30am' do
  runner 'Node.find(:all).each { |n| n.ferret_update }'    
end

every :friday, :at => '11:59pm' do
  runner 'Node.reduce_hit_count'
end

every 5.minutes do
  runner 'NewsViewer.update_news_items; NodeSweeper.sweep_nodes', :timeout => "15m"
end  

every :hour do
  runner 'Event.send_registration_notifications'
end

every 10.minutes do
  runner 'FeedWorker.new.update_feeds'
end     
