class Object
  def to_boolean
    ActiveRecord::ConnectionAdapters::Column.value_to_boolean(self)
  end

  # Tell Rails this file is an extension of a file in another engine
  # This requires the file in the other engine, so that you can reopen
  # classes and modules it defines, and expand their functionality.
  # 
  # * +extended_from+: the engine or module containing the engine from which to extend.
  #   extension_of requires the file with the same path in this engine
  # 
  # * +extended_by+(optional): the engine (or module containing the engine) in which this method is called
  #   this is used to determine the path of this file within it's engine. Default = the current rails app.
  def extension_of(extended_from, extended_by = Rails.application.class)
    # check & normalize arguments
    extended_from, extended_by = *[extended_from, extended_by].map do |mod|
      raise "expected a Module, got #{mod.inspect}" unless mod.is_a?(Module)

      if mod < Rails::Engine
        mod
      elsif mod.const_defined?("Engine") and (mod.const_get("Engine")) < Rails::Engine
        mod.const_get("Engine")
      else
        raise "expected #{mod} to be a subclass of Rails::Engine or to have a namespace-child 'Engine' that is a subclass of Rails::Engine"
      end
    end

    # get the path in the current engine
    path_in_engine = caller.first[/^#{Regexp.escape(extended_by.root.to_s)}\/([^:]*)/, 1]
    
    # raise if not found
    unless path_in_engine
      raise "cannot determine the path of the file you want to extend within your engine's root. Your path: #{caller.first[/^[^:]*/]}, Your engine's root: #{extended_by.root}"
    end

    # load the file in the engine we are extending
    require_dependency (extended_from.root + path_in_engine).to_s
  end
  
end