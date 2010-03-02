class Localey
  
  def initialize app
    @app = app
  end
  
  def locales
    @@locales ||= I18n.available_locales
  end
  
  def pattern
    @@pattern ||= /^\/(#{locales.map{|l| Regexp.escape(l.to_s)}.join('|')})(?=\/|$)/
  end
  
  def call env
    env = filter_locale( env )
    
    status, headers, response = @app.call(env)
    [status, headers, response]
  end
  
  def filter_locale env
    locale = env['PATH_INFO'].match(pattern)[1] rescue nil

    if locale
      I18n.locale = locale
      env['PATH_INFO'].sub!(pattern, '')
    end
    
    env
  end
  
end