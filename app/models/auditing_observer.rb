class AuditingObserver < Auditing::Observer
  observe :node, :page
  
  # TODO: Insert super secure auditing here
  def before_save(record)
    RAILS_DEFAULT_LOGGER.debug ">>>>>>>>>>>>> #{controller.inspect}"
  end
end
