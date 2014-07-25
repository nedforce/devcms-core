Rails.application.config.rewriter.append do
  
  rewrite /^\/(?<query>\?.+)?$/, (lambda do |match, rack_env| 
    begin
      query = match[:query].present? ? match[:query] : ''
      node = Site.find_by_domain!(rack_env['SERVER_NAME']).node
      Node.path_for_node(node, '', '', query).tap { |path| Rails.logger.debug "[DevcmsCore] Rewritten #{match.string} to #{path}" }
    rescue ActiveRecord::RecordNotFound
      match.string
    end
  end)

  rewrite /\/content\/(?<slug>[a-zA-Z0-9_\-]+)(?<query>\?.+)?/, (lambda do |match, rack_env| 
    begin
      node = Node.find(match[:slug])
      query = match[:query] rescue ''
      Node.path_for_node(node, '', '', query).tap { |path| Rails.logger.debug "[DevcmsCore] Rewritten #{match.string} to #{path}" }
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
        site   = Site.find_by_domain!(rack_env['SERVER_NAME'])
        format = match[:format] rescue ''
        query  = match[:query] rescue ''
        
        node = Node.find_node_for_url_alias!(match[:url_alias], site)
        remaining_path = match[:url_alias].sub(/^#{node.url_alias}/, '')
        rewritten_path = Node.path_for_node(node, remaining_path, format, query)
        rewritten_path.tap { |path| Rails.logger.debug "[DevcmsCore] Rewritten #{match.string} to #{path}" }
      rescue ActiveRecord::RecordNotFound
        match.string
      end
      
    else
      match.string
    end
  end)
  
end

