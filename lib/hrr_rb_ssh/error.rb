# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class Error < ::StandardError
  end
end

require 'hrr_rb_ssh/error/closed_transport'
require 'hrr_rb_ssh/error/closed_authentication'
require 'hrr_rb_ssh/error/closed_connection'
