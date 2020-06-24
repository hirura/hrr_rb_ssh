require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Messages
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
        #[DataTypes, Field Name]
        [DataTypes::Byte,      :'message number'],
        [DataTypes::Uint32,    :'recipient channel'],
        [DataTypes::String,    :'request type'],
        [DataTypes::Boolean,   :'want reply'],
      ]

      PTY_REQ_DEFINITION = [
        #[DataTypes, Field Name]
        #[DataTypes::String,   :'request type' : "pty-req"],
        [DataTypes::String,    :'TERM environment variable value'],
        [DataTypes::Uint32,    :'terminal width, characters'],
        [DataTypes::Uint32,    :'terminal height, rows'],
        [DataTypes::Uint32,    :'terminal width, pixels'],
        [DataTypes::Uint32,    :'terminal height, pixels'],
        [DataTypes::String,    :'encoded terminal modes'],
      ]

      X11_REQ_DEFINITION = [
        #[DataTypes, Field Name]
        #[DataTypes::String,   :'request type' : "x11-req"],
        [DataTypes::Boolean,   :'single connection'],
        [DataTypes::String,    :'x11 authentication protocol'],
        [DataTypes::String,    :'x11 authentication cookie'],
        [DataTypes::Uint32,    :'x11 screen number'],
      ]

      ENV_DEFINITION = [
        #[DataTypes, Field Name]
        #[DataTypes::String,   'request type' : "env"],
        [DataTypes::String,    :'variable name'],
        [DataTypes::String,    :'variable value'],
      ]

      SHELL_DEFINITION = [
        #[DataTypes, Field Name]
        #[DataTypes::String,   :'request type' : "shell"],
      ]

      EXEC_DEFINITION = [
        #[DataTypes, Field Name]
        #[DataTypes::String,   :'request type' : "exec"],
        [DataTypes::String,    :'command'],
      ]

      SUBSYSTEM_DEFINITION = [
        #[DataTypes, Field Name]
        #[DataTypes::String,   :'request type' : "subsystem"],
        [DataTypes::String,    :'subsystem name'],
      ]

      WINDOW_CHANGE_DEFINITION = [
        #[DataTypes, Field Name]
        #[DataTypes::String,   :'request type' : "window-change"],
        [DataTypes::Uint32,    :'terminal width, columns'],
        [DataTypes::Uint32,    :'terminal height, rows'],
        [DataTypes::Uint32,    :'terminal width, pixels'],
        [DataTypes::Uint32,    :'terminal height, pixels'],
      ]

      XON_XOFF_DEFINITION = [
        #[DataTypes, Field Name]
        #[DataTypes::String,   :'request type' : "xon-xoff"],
        [DataTypes::Boolean,   :'client can do'],
      ]

      SIGNAL_DEFINITION = [
        #[DataTypes, Field Name]
        #[DataTypes::String,   :'request type' : "signal"],
        [DataTypes::String,    :'signal name'],
      ]

      EXIT_STATUS_DEFINITION = [
        #[DataTypes, Field Name]
        #[DataTypes::String,   :'request type' : "exit-status"],
        [DataTypes::Uint32,    :'exit status'],
      ]

      EXIT_SIGNAL_DEFINITION = [
        #[DataTypes, Field Name]
        #[DataTypes::String,   :'request type' : "exit-signal"],
        [DataTypes::String,    :'signal name'],
        [DataTypes::Boolean,   :'core dumped'],
        [DataTypes::String,    :'error message'],
        [DataTypes::String,    :'language tag'],
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
