class Asset < ActiveRecord::Base
  has_attached_file(
    :upload,
    :styles => {
      :normal => "450x450", 
      :medium => "300x300", 
      :thumb => "100x100",
    }
  )
  
  named_scope :images, :conditions => {
    :upload_content_type => [
      "image/gif",
      "image/jpeg",
      "image/png"
    ]
  }
  
  named_scope :documents, :conditions => {
    :upload_content_type => [
      "application/pdf",
      "text/plain",
      "text/rtf"
    ]
  }
  
  named_scope :audio, :conditions => {
    :upload_content_type => [
      "audio/mpeg",
      "audio/x-m4a",
      "audio/wav",
      "audio/x-wav"
    ]
  }
end
