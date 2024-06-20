# frozen_string_literal: true

require 'logger'
require 'socket'
require 'time'
require 'json'

module Unity
  class Logger < ::Logger
    attr_reader :source, :orig_logger

    VERSION = '1.3.1'

    DEBUG  = 0
    INFO   = 1
    WARN   = 2
    ERROR  = 3
    FATAL  = 4

    JSON_FAST_GENERATE_OPTS = { mode: :null }.freeze
    SEVERITY_KEY = '@severity'
    DATE_KEY     = '@date'
    HOSTNAME_KEY = '@hostname'
    SOURCE_KEY   = '@source'
    MESSAGE_KEY  = 'message'

    def initialize(*args, **kwargs)
      @source = kwargs.delete(:source)
      @local_hostname = kwargs.delete(:hostname) || Socket.gethostname
      super(*args, **kwargs)

      self.formatter = proc do |severity, datetime, progname, arg|
        data = {
          SEVERITY_KEY => severity,
          DATE_KEY     => datetime.utc.iso8601,
          HOSTNAME_KEY => @local_hostname,
          SOURCE_KEY   => @source
        }.merge!(
          arg.is_a?(Hash) ? arg : { MESSAGE_KEY => arg.to_s }
        )
        JSON.fast_generate(data, **JSON_FAST_GENERATE_OPTS) + "\n"
      end
    end

    def source=(arg)
      @source = arg.to_s
    end
  end
end

