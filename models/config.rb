class Config
  class MissingKey < StandardError; end

  def enviroment
    ENV.fetch('RACK_ENV').to_sym
  end

  def development?
    enviroment == :development
  end

  def get(key, default_in_development = nil)
    ENV.fetch(key) { |k| development? ? default_in_development : (raise MissingKey, "please provide '#{k}' enviroment variable") }
  end
end
