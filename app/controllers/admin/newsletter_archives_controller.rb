# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +NewsletterArchive+ objects.
class Admin::NewsletterArchivesController < Admin::AdminController

  acts_as_archive_controller :newsletter_archive

  before_filter :find_newsletter_editions, :only => :show

  require_role [ 'admin', 'final_editor' ], :except => [ :index, :show ]

protected

  def find_newsletter_editions
    @newsletter_editions = @newsletter_archive.newsletter_editions.find_accessible(:all,
                                                            :conditions => [ 'published <> ?', 'unpublished' ],
                                                            :for => current_user,
                                                            :page => {:size => 25, :current => 1})
    @newsletter_editions_for_table  = @newsletter_editions.to_a
    @latest_newsletter_editions     = @newsletter_editions_for_table[0..5]
    @newsletter_editions_for_table -= @latest_newsletter_editions
  end
end
