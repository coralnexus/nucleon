
module Kernel

  #-----------------------------------------------------------------------------
  # Utilities

  def capture
    out     = StringIO.new
    $stdout = out
    
    error   = StringIO.new
    $stderr = error
    
    # Go do stuff!
    yield    
    return out, error
    
  ensure
    $stdout = STDOUT
    $stderr = STDERR
  end
end