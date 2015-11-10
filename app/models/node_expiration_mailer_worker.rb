class NodeExpirationMailerWorker
  class << self
    # Returns the used logger.
    def logger
      Rails.logger
    end

    def notify_authors(node = Node.root)
      logger.info 'Notifying responsible authors of expired content...'
      node.descendants.expired.all.each do |node|
        send_author_notification(node)
      end
    end

    def notify_final_editors
      logger.info 'Notifying responsible final editors of expired content...'
      PrivilegedUser.final_editors.each do |user|
        nodes = user.assigned_nodes.map { |node| node.self_and_descendants.expired(1.week.ago) }.flatten.compact
        logger.debug "Notifying #{user.login} of #{nodes.size} expired nodes."
        send_final_editor_notification(user, nodes) if nodes.present?
      end
    end

    def send_author_notification(node)
      NodeExpirationMailer.author_notification(node).deliver
    rescue Exception => exception
      raise exception unless Rails.env.production?
      Airbrake.notify(exception, data: { message: 'Notifying authors of expired content.', node: node })
    end

    def send_final_editor_notification(final_editor, nodes)
      NodeExpirationMailer.final_editor_notification(final_editor, nodes).deliver
    rescue Exception => exception
      raise exception unless Rails.env.production?
      Airbrake.notify(exception, data: { message: 'Notifying final editor of expired content.', final_editor: final_editor })
    end
  end
end
