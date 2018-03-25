# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Connection
    class RequestHandler
      def initialize &block
        @logger = HrrRbSsh::Logger.new self.class.name
        @proc = block
      end
      def run context
        @proc.call context
      end
    end
  end
end
