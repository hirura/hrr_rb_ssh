# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/message/codable'

module HrrRbSsh
  module Message
    module SSH_MSG_CHANNEL_REQUEST
      module SignalName
        ABRT = 'ABRT'
        ALRM = 'ALRM'
        FPE  = 'FPE'
        HUP  = 'HUP'
        ILL  = 'ILL'
        INT  = 'INT'
        KILL = 'KILL'
        PIPE = 'PIPE'
        QUIT = 'QUIT'
        SEGV = 'SEGV'
        TERM = 'TERM'
        USR1 = 'USR1'
        USR2 = 'USR2'
      end

      class << self
        include Codable
      end

      ID    = self.name.split('::').last
      VALUE = 98

      DEFINITION = [
        # [Data Type, Field Name]
        ['byte',      'SSH_MSG_CHANNEL_REQUEST'],
        ['uint32',    'recipient channel'],
        ['string',    'request type'],
        ['boolean',   'want reply'],
      ]

      PTY_REQ_DEFINITION = [
        # [Data Type, Field Name]
        # ['string',  'request type' : "pty-req"],
        ['string',    'TERM environment variable value'],
        ['uint32',    'terminal width, characters'],
        ['uint32',    'terminal height, rows'],
        ['uint32',    'terminal width, pixels'],
        ['uint32',    'terminal height, pixels'],
        ['string',    'encoded terminal modes'],
      ]

      X11_REQ_DEFINITION = [
        # [Data Type, Field Name]
        # ['string',  'request type' : "x11-req"],
        ['boolean',   'single connection'],
        ['string',    'x11 authentication protocol'],
        ['string',    'x11 authentication cookie'],
        ['uint32',    'x11 screen number'],
      ]

      ENV_DEFINITION = [
        # [Data Type, Field Name]
        # ['string',  'request type' : "env"],
        ['string',    'variable name'],
        ['string',    'variable value'],
      ]

      SHELL_DEFINITION = [
        # [Data Type, Field Name]
        # ['string',  'request type' : "shell"],
      ]

      EXEC_DEFINITION = [
        # [Data Type, Field Name]
        # ['string',  'request type' : "exec"],
        ['string',    'command'],
      ]

      SUBSYSTEM_DEFINITION = [
        # [Data Type, Field Name]
        # ['string',  'request type' : "subsystem"],
        ['string',    'subsystem name'],
      ]

      WINDOW_CHANGE_DEFINITION = [
        # [Data Type, Field Name]
        # ['string',  'request type' : "window-change"],
        ['uint32',    'terminal width, columns'],
        ['uint32',    'terminal height, rows'],
        ['uint32',    'terminal width, pixels'],
        ['uint32',    'terminal height, pixels'],
      ]

      XON_XOFF_DEFINITION = [
        # [Data Type, Field Name]
        # ['string',  'request type' : "xon-xoff"],
        ['boolean',   'client can do'],
      ]

      SIGNAL_DEFINITION = [
        # [Data Type, Field Name]
        # ['string',  'request type' : "signal"],
        ['string',    'signal name'],
      ]

      EXIT_STATUS_DEFINITION = [
        # [Data Type, Field Name]
        # ['string',  'request type' : "exit-status"],
        ['uint32',    'exit status'],
      ]

      EXIT_SIGNAL_DEFINITION = [
        # [Data Type, Field Name]
        # ['string',  'request type' : "exit-signal"],
        ['string',    'signal name'],
        ['boolean',   'core dumped'],
        ['string',    'error message'],
        ['string',    'language tag'],
      ]

      CONDITIONAL_DEFINITION = {
        # Field Name => {Field Value => Conditional Definition}
        'request type' => {
          'pty-req'       => PTY_REQ_DEFINITION,
          'x11-req'       => X11_REQ_DEFINITION,
          'env'           => ENV_DEFINITION,
          'shell'         => SHELL_DEFINITION,
          'exec'          => EXEC_DEFINITION,
          'subsystem'     => SUBSYSTEM_DEFINITION,
          'window-change' => WINDOW_CHANGE_DEFINITION,
          'xon-xoff'      => XON_XOFF_DEFINITION,
          'signal'        => SIGNAL_DEFINITION,
          'exit-status'   => EXIT_STATUS_DEFINITION,
          'exit-signal'   => EXIT_SIGNAL_DEFINITION,
        },
      }
    end
  end
end
