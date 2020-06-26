module HrrRbSsh
  class Transport
    class CompressionAlgorithm
      module Unfunctionable
        include Loggable

        def initialize direction=nil, logger: nil
          self.logger = logger
        end

        def deflate data
          data
        end

        def inflate data
          data
        end

        def close
          nil
        end
      end
    end
  end
end
