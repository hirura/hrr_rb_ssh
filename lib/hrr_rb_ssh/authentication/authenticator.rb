# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class Authentication
    class Authenticator
      def initialize &block
        @proc = block
      end

      def authenticate context
        @proc.call context
      end
    end
  end
end
