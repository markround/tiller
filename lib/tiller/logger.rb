require 'logger'

module Tiller

  class Logger < Logger

    attr_accessor :messages

    def initialize
      super(STDOUT)
      self.messages = []

      self.level = Logger::WARN
      self.level = Logger::INFO if Tiller::config[:verbose]
      self.level = Logger::DEBUG if Tiller::config[:debug]

      self.formatter = proc do |_severity, _datetime, _progname, msg|
        "[#{_datetime}] [#{_severity}] #{msg}\n"
      end

    end

    # Quick hack to remove duplicate informational messages
    def info(msg, options={})
      super(msg) unless self.messages.include?(msg)
      self.messages.push(msg) if options.fetch(:dedup, true)
    end

    # Quick hack to remove duplicate informational messages
    def debug(msg, options={})
      super(msg) unless self.messages.include?(msg)
      self.messages.push(msg) if options.fetch(:dedup, true)
    end

  end

end