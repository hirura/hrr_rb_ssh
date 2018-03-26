# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/connection/channel/proc_chain/chain_context'

module HrrRbSsh
  class Connection
    class Channel
      class ProcChain
        def initialize
          @logger = HrrRbSsh::Logger.new self.class.name
          @q = Queue.new
        end
        def connect next_proc
          @q.enq next_proc
        end
        def call_next *args
          next_proc = @q.deq
          next_proc.call ChainContext.new(self), *args
        end
      end
    end
  end
end
