class NodeExpirationNotifierWorker
  # Returns the used logger.
  def logger
    RAILS_DEFAULT_LOGGER
  end
  
  # Sends emails to all the authors that are responsible for at least one expired node
  def notifyAllAuthors
    logger.info "Finding authors that are responsible for expired content..."
    getResponsibleAuthors.each do |author|
      nodes = getExpiredNodesForAuthor
      sendNotification(author,nodes)
    end
  end
  
  # Send a NodeExpirationNotifier mail to author with a list of all the nodes
  def sendNotification(author,nodes)
    logger.info "Sending a notification..."
    NodeExpirationNotifier.sendNotification(author,nodes)
  end
  
  # Finds all the authors that are responsible for at least one expired node
  def getResponsibleAuthors
  end
  
  
  # Finds all the nodes that have an expiration time and a responsible author
  def getExpiredNodesForAuthor
    
  end
  
end
