class XML::Node
  def replace_with(other) 
    self.next = other
    remove!
  end
end

module Builder
  class XmlBase
    def _escape(text)
      text
    end
  end
end