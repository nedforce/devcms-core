Rails.application.config.rewriter.append do
  
  rewrite /^\/(?<query>\?.+)?$/, (lambda do |match, rack_env| 
    begin
      query = match[:query].present? ? match[:query] : ''
      "/sections/#{Site.find_by_domain!(rack_env['SERVER_NAME']).id}#{query}"
    rescue ActiveRecord::RecordNotFound
      match.string
    end
  end)

  rewrite /\/content\/(?<slug>[a-zA-Z0-9_\-]+)(?<query>\?.+)?/, (lambda do |match, rack_env| 
    begin
      node = Node.find(match[:slug])
      query = match[:query] rescue ''
      Node.path_for_node(node, query).tap{|path| Rails.logger.info "[DevcmsCore] Rewritten #{match.string} to #{path}" }
    rescue ActiveRecord::RecordNotFound     
      match.string
    end
  end)
  
  rewrite /(?<url_alias>(?<slug>[a-zA-Z0-9_\-]+)(\/[a-zA-Z0-9_\-]+)*)\/(?<action>changes.*)(?<query>\?.+)?/, (lambda do |match, rack_env|
    begin
      query = match[:query] rescue ''
      node = Node.find_node_for_url_alias!(match[:url_alias], rack_env['SERVER_NAME'])
      Rails.logger.info "[DevcmsCore] Requesting changes for node #{node.id}"
      "/nodes/#{node.id}/#{match[:action]}"
    rescue ActiveRecord::RecordNotFound
      match.string
    end
  end)  
    
  rewrite /(?<url_alias>(?<slug>[a-zA-Z0-9_\-]+)(\/[a-zA-Z0-9_\-]+)*)(?<query>\?.+)?/, (lambda do |match, rack_env|
    unless Rails.application.config.reserved_slugs.include?(match[:slug])
    
      begin
        query = match[:query] rescue ''
        node = Node.find_node_for_url_alias!(match[:url_alias], rack_env['SERVER_NAME'])        
        Node.path_for_node(node, query).tap{|path| Rails.logger.info "[DevcmsCore] Rewritten #{match.string} to #{path}" }
      rescue ActiveRecord::RecordNotFound
        match.string
      end
      
    else
      match.string
    end
  end)
  
end

