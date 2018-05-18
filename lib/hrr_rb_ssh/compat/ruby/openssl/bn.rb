# coding: utf-8
# vim: et ts=2 sw=2

if RUBY_VERSION < "2.1"
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
