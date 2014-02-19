
class MockInput

  #-----------------------------------------------------------------------------
  # Constructor / Destructor
  
  def initialize(strings)
    if strings.is_a?(String)
      strings = [ strings ]
    end
    @strings = strings
  end
  
  #---
  
  def self.with(strings)
    $stdin = self.new(strings)
    yield
  ensure
    $stdin = STDIN
  end
  
  #-----------------------------------------------------------------------------
  # Accessors / Modifiers

  def gets
    return @strings.shift
  end  
end