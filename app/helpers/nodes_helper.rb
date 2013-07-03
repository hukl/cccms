module NodesHelper
  
  def title_for_node node
    if node.head
      node.head.title
    elsif node.draft
      node.draft.title
    else
      ""
    end
  end

  def revision_for_node node
    if node.head
      node.head.revision
    elsif node.draft
      node.draft.revision
    else
      ""
    end
  end
  
  def truncated_title_for_node node
    if (title = title_for_node node) && title.size > 20
      "<span title='#{title}'>#{truncate(title, 40)}</span>"
    else
      title
    end
  end
  
  def custom_page_templates
    Page.custom_templates.map {|x| [x.gsub("_", " ").titlecase, x]}
  end
  
  def user_list
    User.all.map {|u| [u.login, u.id]}
  end
  
  def event_information
    if @node.event
      "#{@node.event.start_time.to_s(:db)} - #{@node.event.end_time.to_s(:db)} > " \
      "#{link_to 'show', event_path(@node.event)} " \
      "#{link_to 'edit', edit_event_path(@node.event)}"
    else
      "no event attached > #{link_to 'add', new_event_path(:node_id => @node.id)}"
    end
  end
end
