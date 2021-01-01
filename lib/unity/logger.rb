# frozen_string_literal: true

require 'logger'
require 'socket'
require 'time'
require 'json'
require "unity/logger/version"

module Unity
  class Logger
    attr_reader :source

    DEBUG  = 0
    INFO   = 1
    WARN   = 2
    ERROR  = 3
    FATAL  = 4

    def initialize(*args)
      @logger = ::Logger.new(*args)
      @local_hostname = Socket.gethostname
      @source = nil
      @logger.formatter = proc do |severity, datetime, progname, arg|
        JSON.dump(
          {
            '@severity' => severity,
            '@date' => datetime.utc.iso8601,
            '@hostname' => @local_hostname,
            '@source' => @source
          }.merge(
            arg.is_a?(Hash) ? arg : { 'message' => arg.to_s }
          )
        ) + "\n"
      end
    end

    def source=(arg)
      @source = arg.to_s
    end

    def method_missing(method_name, *args, &block)
      @logger.__send__(method_name, *args, &block)
    end
  end
end

