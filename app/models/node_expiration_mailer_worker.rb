class NodeExpirationMailerWorker
  class << self
    # Returns the used logger.
    def logger
      RAILS_DEFAULT_LOGGER
    end

    def notify_authors(node = Node.root)
      logger.info "#{Time.now}: Notifying responsible authors of expired content..."
      node.descendants.expired.all.each do |n|
        send_author_notification(n)
      end
    end

    def notify_final_editors
      logger.info "#{Time.now}: Notifying responsible final editors of expired content..."
      PrivilegedUser.final_editors.each do |user|
        nodes = user.assigned_nodes.collect { |node| node.subtree.expired(1.week.ago) }.flatten.compact
        logger.debug "#{Time.now}: Notifying #{user.login} of #{nodes.size} expired nodes."
        send_final_editor_notification(user, nodes) if nodes.present?
      end
    end

    def send_author_notification(node)
      NodeExpirationMailer.deliver_author_notification(node)
    rescue StandardError => e
      BackgroundNotifier.deliver_exception_notification(e, 'Notifying authors of expired content.', node)
    end

    def send_final_editor_notification(final_editor, nodes)
      NodeExpirationMailer.deliver_final_editor_notification(final_editor, nodes)
    rescue StandardError => e
      BackgroundNotifier.deliver_exception_notification(e, 'Notifying final editor of expired content.', final_editor)
    end
  end
end
