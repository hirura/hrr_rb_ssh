# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/connection/channel/channel_type/channel_type'

module HrrRbSsh
  class Connection
    class Channel
      module ChannelType
        class Session < ChannelType
          NAME = 'session'
        end
      end
    end
  end
end

require 'hrr_rb_ssh/connection/channel/channel_type/session/request_type'
