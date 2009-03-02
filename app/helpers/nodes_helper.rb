module NodesHelper
  
  def title_for_node node
    if node.head
      truncate(node.head.title, :length => 50)
    else
      truncate(node.draft.title, :length => 50)
    end
  end
end
