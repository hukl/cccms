class Asset < ActiveRecord::Base
  has_attached_file( 
    :upload, 
    :styles => { 
      :normal => "450x450", 
      :medium => "300x300", 
      :thumb => "100x100",
      :foo => "bar"
    }
  )
end
