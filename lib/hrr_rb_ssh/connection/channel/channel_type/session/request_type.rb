# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class Connection
    class Channel
      module ChannelType
        class Session
          module RequestType
            def self.list
              RequestType.list
            end

            def self.name_list
              RequestType.name_list
            end

            def self.[] key
              RequestType[key]
            end
          end
        end
      end
    end
  end
end

require 'hrr_rb_ssh/connection/channel/channel_type/session/request_type/request_type'
require 'hrr_rb_ssh/connection/channel/channel_type/session/request_type/pty_req'
require 'hrr_rb_ssh/connection/channel/channel_type/session/request_type/env'
require 'hrr_rb_ssh/connection/channel/channel_type/session/request_type/shell'
require 'hrr_rb_ssh/connection/channel/channel_type/session/request_type/exec'
require 'hrr_rb_ssh/connection/channel/channel_type/session/request_type/subsystem'
