module HrrRbSsh
  module Compat
    module OpenSSL
      # @return [::Boolean] True if the native OpenSSL Version is greater than 3.0.0, false otherwise
      def self.openssl_v3?
        library_string = ::OpenSSL::OPENSSL_VERSION[/OpenSSL (\d+\.\d+\.\d+).*/, 1]
        ::Gem::Version.new(library_string) >= ::Gem::Version.new('3.0.0')
      end

      # @param [::OpenSSL::BN] p
      # @param [::OpenSSL::BN] g
      # @return [::OpenSSL::PKey::DH,::OpenSSL::PKey]
      def self.new_dh_pkey(p:, g:)
        if self.openssl_v3?
          asn1 = ::OpenSSL::ASN1::Sequence(
            [
              ::OpenSSL::ASN1::Integer(p),
              ::OpenSSL::ASN1::Integer(g)
            ]
          )

          dh = ::OpenSSL::PKey::DH.new(asn1.to_der)
          ::OpenSSL::PKey.generate_key(dh)
        else
          dh = ::OpenSSL::PKey::DH.new
          if dh.respond_to?(:set_pqg)
            dh.set_pqg p, nil, g
          else
            dh.p = q
            dh.g = g
          end
          dh.generate_key!
          dh
        end
      end
    end
  end
end
