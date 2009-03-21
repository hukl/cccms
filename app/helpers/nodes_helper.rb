module NodesHelper
  
  def title_for_node node
    if node.head
      node.head.title
    else
      node.draft.title
    end
  end
  
  def custom_page_templates
    Page.custom_templates.map {|x| [x.gsub("_", " ").titlecase, x]}
  end
end
