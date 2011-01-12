module TableBuilder::Format
  ALLOWED_METHODS = [:euro, :dollar, :percent, :lamp]
  
  def euro(x)
    ("%.2f&thinspace;&euro;" % x).gsub(".", ",")
  end
  
  def dollar(x)
    "$&thinspace;%.2f" % x
  end
  
  def percent(x)
    ("%.2f&thinspace;%%" % 100.0*x).gsub(".", ",")
  end
  
  def self.lamp(x)
    
  end
end