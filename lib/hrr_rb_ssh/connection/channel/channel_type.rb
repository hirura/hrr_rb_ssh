# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/subclass_without_preference_listable'

module HrrRbSsh
  class Connection
    class Channel
      class ChannelType
        @subclass_list = Array.new
        class << self
          include SubclassWithoutPreferenceListable
        end
      end
    end
  end
end

require 'hrr_rb_ssh/connection/channel/channel_type/session'
require 'hrr_rb_ssh/connection/channel/channel_type/direct_tcpip'
require 'hrr_rb_ssh/connection/channel/channel_type/forwarded_tcpip'
