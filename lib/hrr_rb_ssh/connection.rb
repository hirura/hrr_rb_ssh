# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Connection
    def initialize authentication, options={}
      @logger = HrrRbSsh::Logger.new self.class.name

      @authentication = authentication
      @options = options
    end
  end
end
