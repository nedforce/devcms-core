class Object
  
  # SHAME!
  def to_bool
    ActiveRecord::ConnectionAdapters::Column.value_to_boolean(self)
  end
  
  alias_method :to_boolean, :to_bool
end
