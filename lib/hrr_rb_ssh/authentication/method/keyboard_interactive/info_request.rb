module HrrRbSsh
  class Authentication
    class Method
      class KeyboardInteractive
        class InfoRequest
          include Loggable

          def initialize name, instruction, language_tag, prompts, logger: nil
            self.logger = logger
            @name         = name
            @instruction  = instruction
            @language_tag = language_tag
            @prompts      = prompts
          end

          def to_message
            message = {
              :'message number' => Messages::SSH_MSG_USERAUTH_INFO_REQUEST::VALUE,
              :'name'           => @name,
              :'instruction'    => @instruction,
              :'language tag'   => @language_tag,
              :'num-prompts'    => @prompts.size,
            }
            message_prompts = @prompts.map.with_index{ |(prompt, echo), i|
              [
                [:"prompt[#{i+1}]", prompt],
                [:"echo[#{i+1}]",   echo],
              ].inject(Hash.new){ |h, (k, v)| h.update({k => v}) }
            }.inject(Hash.new){ |a, b| a.merge(b) }
            message.merge(message_prompts)
          end

          def to_payload
            Messages::SSH_MSG_USERAUTH_INFO_REQUEST.new(logger: logger).encode self.to_message
          end
        end
      end
    end
  end
end
