module HelperExtensions #:nodoc:
  
  def self.included(base)
    base.class_eval do
      include InstanceMethods
      alias_method_chain :compute_public_path, :scope
    end
  end
  
  module InstanceMethods
    
    def asset_scopes #:nodoc:
      @asset_scopes ||= []
    end
    
    # Sets directory scope for asset tag helpers within the given block.
    # 
    # Affects any helper using +compute_public_path+ among which are:
    # +javascript_include_tag+, +stylesheet_include_tag+ and +image_tag+.
    #
    # *Arguments*
    #
    # [dir:]  Either a string, array or number of strings to define the
    #         containing directory.
    #
    # *Examples*
    #
    #   <% with_directory 'ext' do %>
    #      <%= javascript_include_tag 'adapter/ext/ext-base.js', 'ext-all.js' %>
    #      <%= stylesheet_include_tag 'ext-all.css' %>
    #   <% end %>
    #
    # Will generate:
    #
    #   <script ... src="/javascripts/ext/adapter/ext/ext-base.js" ...></script>
    #   <script ... src="/javascripts/ext/ext-all.js" ...></script>
    #   <link ... href="/stylesheets/ext/ext-all.css" .../>
    #   
    # Multiple containing directories:
    # 
    #   <% with_directory 'ext/ux' do %>
    #     <%= javascript_include_tag 'Sorter', 'Sortlet' %>
    #   <% end %>
    #   
    # or with seperate arguments:
    #   
    #   <% with_directory 'ext', 'ux' do %>
    #     <%= javascript_include_tag 'Sorter', 'Sortlet' %>
    #   <% end %>
    #   
    # or with an array of directory names:
    #   
    #   <% with_directory %w(ext ux) do %>
    #     <%= javascript_include_tag 'Sorter', 'Sortlet' %>
    #   <% end %>
    # 
    # or by nesting:
    # 
    #   <% with_directory 'ext' do %>
    #     <% with_directory 'ux' do %>
    #       <%= javascript_include_tag 'Sorter', 'Sortlet' %>
    #     <% end  %>
    #   <% end %>
    #    
    # Will generate:
    #
    #   <script ... src="/javascripts/ext/ux/Sorter.js" ...></script>
    #   <script ... src="/javascripts/ext/ux/Sortlet.js" ...></script>
    #
    def with_directory(*dirs)
      self.asset_scopes << dirs
      begin
        yield
      ensure
        self.asset_scopes.pop
      end
    end
       
    private
    
    def compute_public_path_with_scope(source, dir, ext = nil, include_host = true) #:nodoc:
      source = File.join([self.asset_scopes, source].flatten)
      compute_public_path_without_scope(source, dir, ext, include_host)
    end
  end
end
