module HrrRbSsh
  class Transport
    class KexAlgorithms
      include Loggable

      def initialize logger: nil
        self.logger = logger

        @kex_algorithms = self.class.constants.map{|c| self.class.const_get(c)}.select{|c| c.respond_to?(:const_defined?) && c.const_defined?(:NAME)}.inject({}){|h,c| h.update({c::NAME => c})}
        @list_supported = @kex_algorithms.keys
        @list_preferred = @kex_algorithms.values.select{|c| c::PREFERENCE > 0}.sort_by{|c| c::PREFERENCE}.reverse.map{|c| c::NAME}
      end

      def list_supported
        @list_supported
      end

      def list_preferred
        @list_preferred
      end

      def instantiate name
        @kex_algorithms[name].new(logger: logger)
      end
    end
  end
end

require 'hrr_rb_ssh/transport/kex_algorithms/iv_computable'
require "hrr_rb_ssh/transport/kex_algorithms/diffie_hellman"
require 'hrr_rb_ssh/transport/kex_algorithms/diffie_hellman_group_exchange'
require "hrr_rb_ssh/transport/kex_algorithms/elliptic_curve_diffie_hellman"
require "hrr_rb_ssh/transport/kex_algorithms/diffie_hellman_group1_sha1"
require "hrr_rb_ssh/transport/kex_algorithms/diffie_hellman_group14_sha1"
require "hrr_rb_ssh/transport/kex_algorithms/diffie_hellman_group14_sha256"
require "hrr_rb_ssh/transport/kex_algorithms/diffie_hellman_group15_sha512"
require "hrr_rb_ssh/transport/kex_algorithms/diffie_hellman_group16_sha512"
require "hrr_rb_ssh/transport/kex_algorithms/diffie_hellman_group17_sha512"
require "hrr_rb_ssh/transport/kex_algorithms/diffie_hellman_group18_sha512"
require "hrr_rb_ssh/transport/kex_algorithms/diffie_hellman_group_exchange_sha1"
require "hrr_rb_ssh/transport/kex_algorithms/diffie_hellman_group_exchange_sha256"
require "hrr_rb_ssh/transport/kex_algorithms/elliptic_curve_diffie_hellman_sha2_nistp256"
require "hrr_rb_ssh/transport/kex_algorithms/elliptic_curve_diffie_hellman_sha2_nistp384"
require "hrr_rb_ssh/transport/kex_algorithms/elliptic_curve_diffie_hellman_sha2_nistp521"
