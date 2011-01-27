def class_exists?(class_name, options = {})
  class_exists = Module.const_get(class_name).is_a?(Class)  
  return (class_exists && options[:constantize]) ? class_name.constantize : class_exists
rescue NameError
  return false
end