# Buffer structure.
#
class Tidybuf

  extend DL::Importable
  
  # Access TidyBuffer instance.
  #
  attr_reader(:struct)

  def initialize(tidy_path)
    @tidy_path = tidy_path
    struct_def = if PLATFORM =~ /win32/ || `strings #{@tidy_path} | grep prvTidy`.blank? # newer versions prefix symbols with prvTidy
      self.class.struct [
        "byte* bp",
        "uint size",
        "uint allocated",
        "uint next"
      ]
    else
      self.class.struct [
        "int* allocator",
        "byte* bp",
        "uint size",
        "uint allocated",
        "uint next"
      ]
    end
    @struct = struct_def.malloc
  end
    
  # Free current contents and zero out.
  #
  def free
    Tidylib.buf_free(@struct)
  end

  # Convert to array.
  #
  def to_a
    to_s.split($/)
  end

  # Convert to string.
  #
  def to_s
    @struct.bp ? @struct.bp.to_s(@struct.size) : ''
  end

end
