# coding: utf-8
# vim: et ts=2 sw=2

if RUBY_VERSION < "2.3"
  require 'timeout'

  class ClosedQueueError < StandardError
  end

  class Queue
    alias_method :__enq__, :enq
    alias_method :__deq__, :deq

    def close
      @closed = true
    end

    def closed?
      @closed == true
    end

    def enq arg
      raise ClosedQueueError if @closed == true
      __enq__ arg
    end

    def deq
      begin
        Timeout.timeout(0.1) do
          __deq__
        end
      rescue Timeout::Error
        return nil if @closed == true
        retry
      end
    end
  end
end
