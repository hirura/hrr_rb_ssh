# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class Connection
    class Channel
      class ChannelType
        class Session
          class ProcChain
            class ChainContext
              def initialize proc_chain
                @proc_chain = proc_chain
              end
              def call_next *args
                @proc_chain.call_next *args
              end
            end
          end
        end
      end
    end
  end
end
