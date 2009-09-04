class XML::Node
  def replace_with(other) 
    self.next = other
    remove!
  end
end