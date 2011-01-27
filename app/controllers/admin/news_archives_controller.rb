# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +NewsArchive+ objects.
class Admin::NewsArchivesController < Admin::AdminController
  
  acts_as_archive_controller :news_archive, :date_attribute => :publication_start_date

  before_filter :find_recent_news_items, :only => :show

  require_role [ 'admin', 'final_editor' ], :except => [:index, :show]
  
protected

  # Finds recent news items.
  def find_recent_news_items
    @news_items = @news_archive.news_items.find_accessible(:all,
                                                           :include => [ :node ],
                                                           :for => current_user,
                                                           :approved_content => true,
                                                           :page => { :size => 25, :current => 1 }
                                                          )
    @news_items_for_table  = @news_items.to_a
    @latest_news_items     = @news_items_for_table[0..7]
    @news_items_for_table -= @latest_news_items
  end

end
