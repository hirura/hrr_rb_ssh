# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/connection/channel/session/pty_req'
require 'hrr_rb_ssh/connection/channel/session/env'
require 'hrr_rb_ssh/connection/channel/session/shell'
require 'hrr_rb_ssh/connection/channel/session/exec'
require 'hrr_rb_ssh/connection/channel/session/subsystem'

module HrrRbSsh
  class Connection
    class Channel
      channel_type = 'session'

      module Session
        @@request_type_list ||= Hash.new

        def self.[] key
          @@request_type_list[key]
        end

        def self.request_type_list
          @@request_type_list.keys
        end
      end

      @@type_list ||= Hash.new
      @@type_list[channel_type] = Session
    end
  end
end
