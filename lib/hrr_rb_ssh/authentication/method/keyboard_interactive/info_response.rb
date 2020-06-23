# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class Authentication
    class Method
      class KeyboardInteractive
        class InfoResponse
          include Loggable

          attr_reader \
            :num_responses,
            :responses

          def initialize payload, logger: nil
            self.logger = logger
            case payload[0,1].unpack("C")[0]
            when Messages::SSH_MSG_USERAUTH_INFO_RESPONSE::VALUE
              message = Messages::SSH_MSG_USERAUTH_INFO_RESPONSE.new(logger: logger).decode payload
              @num_responses = message[:'num-responses']
              @responses = Array.new(message[:'num-responses']){ |i| message[:"response[#{i+1}]"] }
            else
              raise "Expected SSH_MSG_USERAUTH_INFO_RESPONSE, but got message number #{payload[0,1].unpack("C")[0]}"
            end
          end
        end
      end
    end
  end
end
