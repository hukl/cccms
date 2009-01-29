module CollectiveIdea
  module Acts #:nodoc:
    module NestedSet
      module InstanceMethods
        alias_method :move_to_original, :move_to
        
        def move_to target, position
          move_to_original target, position
          if self.class == Node
            self.update_unique_name
            self.save
          end
        end
      end
    end
  end
end