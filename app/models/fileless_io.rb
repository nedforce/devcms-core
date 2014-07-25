class FilelessIO < StringIO
  attr_accessor :original_filename, :content_type
  attr_writer   :size

  def size
    @size || super
  end
end
