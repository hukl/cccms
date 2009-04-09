require 'csv'


class AuthorsImporter
  
  def initialize path
    if File.exists? path
      @parsed_file = CSV::Reader.parse(File.open(path, "r"))
    else
      raise "File does not exist"
    end
  end
  
  def import_authors
    @parsed_file.each do |row|
      password = generate_password
      
      options = {
        :login                  => row[0],
        :full_name              => row[1],
        :email                  => row[2],
        :password               => password,
        :password_confirmation  => password
      }
      
      unless user = User.find_by_email(options[:email])
        User.create options
      end
    end
  end
  
  def generate_password
    Digest::SHA1.hexdigest("#{Time.now+rand(10000).days}")
  end
end