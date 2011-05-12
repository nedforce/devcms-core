class NodeExpirationMailerWorker
  
  class << self
    # Returns the used logger.
    def logger
      RAILS_DEFAULT_LOGGER
    end
  
    def notify_authors
      logger.info "Notifying responsible authors of expired content..."
      Node.expired.all.group_by(&:responsible_user).each do |author, nodes|
        logger.debug "Notifying #{author.login} of #{nodes.size} expired nodes."
        send_author_notification(author, nodes) if nodes.present?
      end
    end
    
    def notify_final_editors
      logger.info "Notifying responsible final editors of expired content..."
      User.final_editors.each do |user|
        nodes = user.assigned_nodes.collect { |node| node.self_and_descendants.expired(1.week.ago) }.flatten.compact
        logger.debug "Notifying #{user.login} of #{nodes.size} expired nodes."
        send_final_editor_notification(user, nodes) if nodes.present?
      end
    end
  
    def send_author_notification(author,nodes)
      begin
        NodeExpirationMailer.deliver_author_notification(author,nodes)
      rescue Exception => exception
        BackgroundNotifier.deliver_exception_notification(exception, "Notifying authors of expired content.", author)
      end
    end
    
    def send_final_editor_notification(final_editor,nodes)
      begin
        NodeExpirationMailer.deliver_final_editor_notification(final_editor,nodes)
      rescue Exception => exception
        BackgroundNotifier.deliver_exception_notification(exception, "Notifying final editor of expired content.", final_editor)
      end
    end
  end
end
