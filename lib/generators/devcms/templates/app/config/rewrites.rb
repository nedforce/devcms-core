Rails.application.config.rewriter.append do
  # Documentation: https://github.com/jtrupiano/rack-rewrite
  
  # Maintenance page example, activate by running something like:
  # cap deploy:web:disable REASON=upgrade UNTIL=12:30PM
  
  # maintenance_file = File.join(Rails.root, 'public', 'system', 'maintenance.html')
  # send_file /(.*)$(?<!css|png|jpg)/, maintenance_file, :if => Proc.new { |rack_env|
  #   File.exists?(maintenance_file)
  # }
  
  # Redirect example
  
  # r302 '/help', '/contact'
  
  # Rewrite example
  
  # rewrite '/faq', (lambda do |match, rack_env| 
  #   begin
  #     node = Node.where([ 'url_alias = ? OR custom_url_alias = ?', 'faq', 'faq' ]).first!
  #     Node.path_for_node(node).tap { |path| Rails.logger.info "Rewritten #{match.string} to #{path}" }
  #   rescue ActiveRecord::RecordNotFound     
  #     match.string
  #   end
  # end)
  
end
