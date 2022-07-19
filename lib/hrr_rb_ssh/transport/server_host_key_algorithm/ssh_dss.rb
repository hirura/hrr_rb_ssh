require 'hrr_rb_ssh/transport/server_host_key_algorithm/functionable'

module HrrRbSsh
  class Transport
    class ServerHostKeyAlgorithm
      class SshDss < ServerHostKeyAlgorithm
        NAME = 'ssh-dss'
        PREFERENCE = 10
        SECRET_KEY = OpenSSL::PKey.respond_to?(:generate_key) ?
            OpenSSL::PKey.generate_key(
              OpenSSL::PKey.generate_parameters('DSA', {
                # The number of bits in the generated prime
                'dsa_paramgen_bits' => 1024,
                # The number of bits in the q parameter. Must be one of 160, 224 or 256. If not specified 224 is used.
                # This must align with an allowed combination from Section 4.2 in
                # https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.186-4.pdf
                'dsa_paramgen_q_bits' => 160
              })
            ).to_pem
          : OpenSSL::PKey::DSA.new(1024).to_pem

        include Functionable
      end
    end
  end
end
