# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/version'
require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Transport
    def initialize io, mode
      @io = io
      @mode = mode

      @logger = HrrRbSsh::Logger.new self.class.name
    end
  end
end
