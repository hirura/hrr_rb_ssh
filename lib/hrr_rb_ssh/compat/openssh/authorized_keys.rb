module HrrRbSsh
  module Compat
    module OpenSSH
      class AuthorizedKeys
        def initialize data_str
          @public_keys = data_str.each_line.map{ |line|
            PublicKey.new line
          }
        end

        def each
          @public_keys.each{ |public_key|
            yield public_key
          }
        end

        include Enumerable
      end
    end
  end
end
