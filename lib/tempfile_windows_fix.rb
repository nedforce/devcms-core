require 'tempfile'

class Tempfile
  def size
    if @tmpfile
      @tmpfile.fsync # this is what Windows needs
      @tmpfile.flush
      @tmpfile.stat.size
    else
      0
    end
  end
end
