# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class Connection
    class Channel
      module ChannelType
        def self.list
          ChannelType.list
        end

        def self.name_list
          ChannelType.name_list
        end

        def self.[] key
          ChannelType[key]
        end
      end
    end
  end
end

require 'hrr_rb_ssh/connection/channel/channel_type/channel_type'
require 'hrr_rb_ssh/connection/channel/channel_type/session'
