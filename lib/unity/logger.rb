# frozen_string_literal: true

require 'logger'
require 'socket'
require 'time'
require 'json'
require "unity/logger/version"

module Unity
  class Logger
    attr_reader :source

    def initialize(*args)
      @logger = ::Logger.new(*args)
      @local_hostname = Socket.gethostname
      @source = Unity.respond_to?(:application) ? Unity.application&.name : nil
      @logger.formatter = proc do |severity, datetime, progname, msg|
        JSON.dump(
          {
            '@severity' => severity,
            '@date' => datetime.utc.iso8601,
            '@hostname' => @local_hostname,
            '@source' => @source
          }.merge(
            msg.is_a?(Hash) ? row : { 'message' => msg.to_s }
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
