require 'logger'

module Tiller

  class Logger < Logger
    def initialize
      super(STDOUT)

      self.level = Logger::WARN
      self.level = Logger::INFO if Tiller::config[:verbose]
      self.level = Logger::DEBUG if Tiller::config[:debug]

      self.formatter = proc do |_severity, _datetime, _progname, msg|
        "#{msg}\n"
      end

    end
  end

end