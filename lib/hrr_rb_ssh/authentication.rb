# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/message'

module HrrRbSsh
  class Authentication
    def initialize transport
      @transport = transport

      @logger = HrrRbSsh::Logger.new self.class.name
    end
  end
end
