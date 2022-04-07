# frozen_string_literal: true

require 'logger'
require 'socket'
require 'time'
require 'json'

module Unity
  class Logger < ::Logger
    attr_reader :source, :orig_logger

    VERSION = '1.3.0'

    DEBUG  = 0
    INFO   = 1
    WARN   = 2
    ERROR  = 3
    FATAL  = 4

    def initialize(*args, **kwargs)
      @source = kwargs.delete(:source)
      @local_hostname = kwargs.delete(:hostname) || Socket.gethostname
      super(*args, **kwargs)

      self.formatter = proc do |severity, datetime, progname, arg|
        JSON.fast_generate(
          {
            '@severity' => severity,
            '@date' => datetime.utc.iso8601,
            '@hostname' => @local_hostname,
            '@source' => @source
          }.merge!(
            arg.is_a?(Hash) ? arg : { 'message' => arg.to_s }
          ),
          mode: :null
        ) + "\n"
      end
    end

    def source=(arg)
      @source = arg.to_s
    end
  end
end

