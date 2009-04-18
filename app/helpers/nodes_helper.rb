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
  
  
  def event_information
    if @node.event
      "#{@node.event.start_time} - #{@node.event.end_time} > #{link_to 'edit', edit_event_path(@node.event)}"
    else
      "no event attached > #{link_to 'add', new_event_path(:event_node_id => @node.id)}"
    end
  end
end
