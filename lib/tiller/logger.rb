require 'logger'

module Tiller

  class Logger < Logger
    def initialize(config)
      super(STDOUT)

      self.level = Logger::WARN
      self.level = Logger::INFO if config[:verbose]
      self.level = Logger::DEBUG if config[:debug]

      self.formatter = proc do |_severity, _datetime, _progname, msg|
        "#{msg}\n"
      end

    end
  end

end