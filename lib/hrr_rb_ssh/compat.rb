# coding: utf-8
# vim: et ts=2 sw=2

if RUBY_VERSION < "2.1"
  class Array
    def to_h
      h = Hash.new
      self.each do |k, v|
        h[k] = v
      end
      h
    end
  end

  require 'openssl'
  class OpenSSL::BN
    alias_method :__initialize__, :initialize

    def initialize *args
      args[0] = case args[0]
                when OpenSSL::BN, Fixnum, Bignum
                  args[0].to_s
                else
                  args[0]
                end
      __initialize__ *args
    end
  end
end

if RUBY_VERSION < "2.3"
  class ClosedQueueError < StandardError
  end

  class Queue
    require 'timeout'

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
