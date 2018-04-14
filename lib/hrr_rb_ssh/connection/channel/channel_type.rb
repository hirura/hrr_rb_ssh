# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class Connection
    class Channel
      class ChannelType
        @subclass_list = Array.new
        class << self
          def inherited klass
            @subclass_list.push klass if @subclass_list
          end

          def [] key
            __subclass_list__(__method__).find{ |klass| klass::NAME == key }
          end

          def __subclass_list__ method_name
            send(:method_missing, method_name) unless @subclass_list
            @subclass_list
          end

          private :__subclass_list__
        end
      end
    end
  end
end

require 'hrr_rb_ssh/connection/channel/channel_type/session'
