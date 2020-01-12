# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Message
    class SSH_MSG_CHANNEL_REQUEST
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

      module TerminalMode
        TTY_OP_END    =   0
        VINTR         =   1
        VQUIT         =   2
        VERASE        =   3
        VKILL         =   4
        VEOF          =   5
        VEOL          =   6
        VEOL2         =   7
        VSTART        =   8
        VSTOP         =   9
        VSUSP         =  10
        VDSUSP        =  11
        VREPRINT      =  12
        VWERASE       =  13
        VLNEXT        =  14
        VFLUSH        =  15
        VSWTCH        =  16
        VSTATUS       =  17
        VDISCARD      =  18
        IGNPAR        =  30
        PARMRK        =  31
        INPCK         =  32
        ISTRIP        =  33
        INLCR         =  34
        IGNCR         =  35
        ICRNL         =  36
        IUCLC         =  37
        IXON          =  38
        IXANY         =  39
        IXOFF         =  40
        IMAXBEL       =  41
        ISIG          =  50
        ICANON        =  51
        XCASE         =  52
        ECHO          =  53
        ECHOE         =  54
        ECHOK         =  55
        ECHONL        =  56
        NOFLSH        =  57
        TOSTOP        =  58
        IEXTEN        =  59
        ECHOCTL       =  60
        ECHOKE        =  61
        PENDIN        =  62
        OPOST         =  70
        OLCUC         =  71
        ONLCR         =  72
        OCRNL         =  73
        ONOCR         =  74
        ONLRET        =  75
        CS7           =  90
        CS8           =  91
        PARENB        =  92
        PARODD        =  93
        TTY_OP_ISPEED = 128
        TTY_OP_OSPEED = 129
      end

      include Codable

      ID    = self.name.split('::').last
      VALUE = 98

      TERMINAL_MODE_INV = TerminalMode.constants.map{|c| [TerminalMode.const_get(c), c.to_s]}.inject(Hash.new){ |h, (k, v)| h.update({k => v}) }

      DEFINITION = [
        #[DataType, Field Name]
        [DataType::Byte,      :'message number'],
        [DataType::Uint32,    :'recipient channel'],
        [DataType::String,    :'request type'],
        [DataType::Boolean,   :'want reply'],
      ]

      PTY_REQ_DEFINITION = [
        #[DataType, Field Name]
        #[DataType::String,   :'request type' : "pty-req"],
        [DataType::String,    :'TERM environment variable value'],
        [DataType::Uint32,    :'terminal width, characters'],
        [DataType::Uint32,    :'terminal height, rows'],
        [DataType::Uint32,    :'terminal width, pixels'],
        [DataType::Uint32,    :'terminal height, pixels'],
        [DataType::String,    :'encoded terminal modes'],
      ]

      X11_REQ_DEFINITION = [
        #[DataType, Field Name]
        #[DataType::String,   :'request type' : "x11-req"],
        [DataType::Boolean,   :'single connection'],
        [DataType::String,    :'x11 authentication protocol'],
        [DataType::String,    :'x11 authentication cookie'],
        [DataType::Uint32,    :'x11 screen number'],
      ]

      ENV_DEFINITION = [
        #[DataType, Field Name]
        #[DataType::String,   'request type' : "env"],
        [DataType::String,    :'variable name'],
        [DataType::String,    :'variable value'],
      ]

      SHELL_DEFINITION = [
        #[DataType, Field Name]
        #[DataType::String,   :'request type' : "shell"],
      ]

      EXEC_DEFINITION = [
        #[DataType, Field Name]
        #[DataType::String,   :'request type' : "exec"],
        [DataType::String,    :'command'],
      ]

      SUBSYSTEM_DEFINITION = [
        #[DataType, Field Name]
        #[DataType::String,   :'request type' : "subsystem"],
        [DataType::String,    :'subsystem name'],
      ]

      WINDOW_CHANGE_DEFINITION = [
        #[DataType, Field Name]
        #[DataType::String,   :'request type' : "window-change"],
        [DataType::Uint32,    :'terminal width, columns'],
        [DataType::Uint32,    :'terminal height, rows'],
        [DataType::Uint32,    :'terminal width, pixels'],
        [DataType::Uint32,    :'terminal height, pixels'],
      ]

      XON_XOFF_DEFINITION = [
        #[DataType, Field Name]
        #[DataType::String,   :'request type' : "xon-xoff"],
        [DataType::Boolean,   :'client can do'],
      ]

      SIGNAL_DEFINITION = [
        #[DataType, Field Name]
        #[DataType::String,   :'request type' : "signal"],
        [DataType::String,    :'signal name'],
      ]

      EXIT_STATUS_DEFINITION = [
        #[DataType, Field Name]
        #[DataType::String,   :'request type' : "exit-status"],
        [DataType::Uint32,    :'exit status'],
      ]

      EXIT_SIGNAL_DEFINITION = [
        #[DataType, Field Name]
        #[DataType::String,   :'request type' : "exit-signal"],
        [DataType::String,    :'signal name'],
        [DataType::Boolean,   :'core dumped'],
        [DataType::String,    :'error message'],
        [DataType::String,    :'language tag'],
      ]

      CONDITIONAL_DEFINITION = {
        # Field Name => {Field Value => Conditional Definition}
        :'request type' => {
          "pty-req"       => PTY_REQ_DEFINITION,
          "x11-req"       => X11_REQ_DEFINITION,
          "env"           => ENV_DEFINITION,
          "shell"         => SHELL_DEFINITION,
          "exec"          => EXEC_DEFINITION,
          "subsystem"     => SUBSYSTEM_DEFINITION,
          "window-change" => WINDOW_CHANGE_DEFINITION,
          "xon-xoff"      => XON_XOFF_DEFINITION,
          "signal"        => SIGNAL_DEFINITION,
          "exit-status"   => EXIT_STATUS_DEFINITION,
          "exit-signal"   => EXIT_SIGNAL_DEFINITION,
        },
      }
    end
  end
end
