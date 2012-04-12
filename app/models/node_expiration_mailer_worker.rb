class NodeExpirationMailerWorker
  
  class << self
    # Returns the used logger.
    def logger
      RAILS_DEFAULT_LOGGER
    end
  
    def notify_authors(node = Node.root)
      logger.info "Notifying responsible authors of expired content..."
      node.descendants.expired.all.each do |node|
        send_author_notification(node)
      end
    end
    
    def notify_final_editors
      logger.info "Notifying responsible final editors of expired content..."
      PrivilegedUser.final_editors.each do |user|
        nodes = user.assigned_nodes.collect { |node| node.self_and_descendants.expired(1.week.ago) }.flatten.compact
        logger.debug "Notifying #{user.login} of #{nodes.size} expired nodes."
        send_final_editor_notification(user, nodes) if nodes.present?
      end
    end
  
    def send_author_notification(node)
      begin
        NodeExpirationMailer.deliver_author_notification(node)
      rescue Exception => exception
        BackgroundNotifier.deliver_exception_notification(exception, "Notifying authors of expired content.", node)
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
