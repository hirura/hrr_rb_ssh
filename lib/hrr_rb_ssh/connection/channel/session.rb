# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class Connection
    class Channel
      channel_type = 'session'

      module Session
      end

      @@type_list ||= Hash.new
      @@type_list[channel_type] = Session
    end
  end
end
