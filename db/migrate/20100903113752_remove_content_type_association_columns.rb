class RemoveContentTypeAssociationColumns < ActiveRecord::Migration
  def self.up
    remove_column :news_items, :news_archive_id
    remove_column :newsletter_editions, :newsletter_archive_id
    remove_column :weblogs, :weblog_archive_id  
    remove_column :weblog_posts, :weblog_id
    remove_column :forum_topics, :forum_id
    remove_column :poll_questions, :poll_id    
    remove_column :events, :calendar_id  
    remove_column :agenda_items, :event_id
  
  end

  def self.down
    add_column :agenda_items, :event_id, :integer, :references => :events
    add_index  :agenda_items, :event_id 
        
    add_column :events, :calendar_id, :integer, :references => :calendars
    add_index  :events, :calendar_id 
    
    add_column :poll_questions, :poll_id, :integer, :references => :polls
    add_index  :poll_questions, :poll_id 
        
    add_column :forum_topics, :forum_id, :integer, :references => :forums
    add_index  :forum_topics, :forum_id 
    
    add_column :weblog_posts, :weblog_id, :integer, :references => :weblogs
    add_index  :weblog_posts, :weblog_id 
    
    add_column :weblogs, :weblog_archive_id, :integer, :references => :weblog_archives
    add_index  :weblogs, :weblog_archive_id     
    
    add_column :newsletter_editions, :newsletter_archive_id, :integer, :references => :newsletter_archives    
    add_index  :newsletter_editions, :newsletter_archive_id 
    
    add_column :news_items, :news_archive_id, :integer, :references => :news_archives  
    add_index  :news_items, :news_archive_id     
  end
end
