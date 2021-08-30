# frozen_string_literal: true

require 'logger'
require 'socket'
require 'time'
require 'oj'
require 'unity/logger/version'

module Unity
  class Logger
    attr_reader :source, :orig_logger

    DEBUG  = 0
    INFO   = 1
    WARN   = 2
    ERROR  = 3
    FATAL  = 4

    def initialize(*args, **kwargs)
      @source = kwargs.delete(:source)
      @local_hostname = kwargs.delete(:hostname) || Socket.gethostname
      @orig_logger = ::Logger.new(*args, **kwargs)
      @orig_logger.formatter = proc do |severity, datetime, progname, arg|
        Oj.dump(
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

    def method_missing(method_name, *args, &block)
      @orig_logger.__send__(method_name, *args, &block)
    end
  end
end

