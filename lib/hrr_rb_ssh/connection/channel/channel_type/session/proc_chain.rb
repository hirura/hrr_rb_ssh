# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/connection/channel/channel_type/session/proc_chain/chain_context'

module HrrRbSsh
  class Connection
    class Channel
      class ChannelType
        class Session
          class ProcChain
            def initialize
              @q = Queue.new
            end
            def connect next_proc
              @q.enq next_proc if next_proc
            end
            def call_next *args
              next_proc = @q.deq
              next_proc.call ChainContext.new(self), *args
            end
          end
        end
      end
    end
  end
end
