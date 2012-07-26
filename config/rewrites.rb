Rails.application.config.rewriter.append do
  
  rewrite /^\/(?<query>\?.+)?$/, (lambda do |match, rack_env| 
    begin
      query = match[:query].present? ? match[:query] : ''
      node = Site.find_by_domain!(rack_env['SERVER_NAME']).node
      Node.path_for_node(node, '', '', query).tap{|path| Rails.logger.debug "[DevcmsCore] Rewritten #{match.string} to #{path}" }
    rescue ActiveRecord::RecordNotFound
      match.string
    end
  end)

  rewrite /\/content\/(?<slug>[a-zA-Z0-9_\-]+)(?<query>\?.+)?/, (lambda do |match, rack_env| 
    begin
      node = Node.find(match[:slug])
      query = match[:query] rescue ''
      Node.path_for_node(node, '', '', query).tap{|path| Rails.logger.debug "[DevcmsCore] Rewritten #{match.string} to #{path}" }
    rescue ActiveRecord::RecordNotFound     
      match.string
    end
  end)
  
  rewrite /(?<url_alias>(?<slug>[a-zA-Z0-9_\-]+)(\/[a-zA-Z0-9_\-]+)*)\/(?<action>changes.*)(?<query>\?.+)?/, (lambda do |match, rack_env|
    begin

      query = match[:query] rescue ''
      node = Node.find_node_for_url_alias!(match[:url_alias], Site.find_by_domain!(rack_env['SERVER_NAME']))
      "/nodes/#{node.id}/#{match[:action]}"
    rescue ActiveRecord::RecordNotFound
      match.string
    end
  end)  
    
  rewrite /(?<url_alias>(?<slug>[a-zA-Z0-9_\-]+)(\/[a-zA-Z0-9_\-]+)*)(?<format>\.[a-zA-Z]+)?(?<query>\?.+)?/, (lambda do |match, rack_env|
    unless Rails.application.config.reserved_slugs.include?(match[:slug])
      begin 
        site = Site.find_by_domain!(rack_env['SERVER_NAME'])
        format = match[:format] rescue ''
        query = match[:query] rescue ''
        slugs = match[:url_alias].split('/')
        
        if slugs.size > 1 && node = Node.find_node_for_url_alias(slugs[0..-2].join('/'), site)
          begin
            # Check whether the last slug is an action on the node
            rewritten_path = Node.path_for_node(node, '/' + slugs.last, format, query)
            Rails.application.routes.recognize_path(rewritten_path)
            rewritten_path.tap{|path| Rails.logger.debug "[DevcmsCore] Rewritten #{match.string} to #{path}" }
          rescue ActionController::RoutingError
            # Consider the last slug as part of the URL alias otherwise
            node = node.children.find_node_for_url_alias!(match[:url_alias], site)
            Node.path_for_node(node, '', format, query).tap{|path| Rails.logger.debug "[DevcmsCore] Rewritten #{match.string} to #{path}" }          
          end
        else
          # Match must be an URL alias as a whole
          node = Node.find_node_for_url_alias!(match[:url_alias], site)
          Node.path_for_node(node, '', format, query).tap{|path| Rails.logger.debug "[DevcmsCore] Rewritten #{match.string} to #{path}" }
        end

      rescue ActiveRecord::RecordNotFound
        match.string
      end
      
    else
      match.string
    end
  end)
  
end

