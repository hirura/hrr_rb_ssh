# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/connection/request_handler'

module HrrRbSsh
  class Connection
    class Channel
      module Session
        request_type = 'pty-req'

        class PtyReq
        end

        @@request_type_list ||= Hash.new
        @@request_type_list[request_type] = PtyReq
      end
    end
  end
end
