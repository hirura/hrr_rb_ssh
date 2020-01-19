# HrrRbSsh

[![Build Status](https://travis-ci.org/hirura/hrr_rb_ssh.svg?branch=master)](https://travis-ci.org/hirura/hrr_rb_ssh)
[![Maintainability](https://api.codeclimate.com/v1/badges/f5dfdb97d72f24ca5939/maintainability)](https://codeclimate.com/github/hirura/hrr_rb_ssh/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/f5dfdb97d72f24ca5939/test_coverage)](https://codeclimate.com/github/hirura/hrr_rb_ssh/test_coverage)
[![Gem Version](https://badge.fury.io/rb/hrr_rb_ssh.svg)](https://badge.fury.io/rb/hrr_rb_ssh)

hrr_rb_ssh is a pure Ruby SSH 2.0 server and client implementation.

With hrr_rb_ssh, it is possible to write an SSH server easily, and also possible to write an original server side application on secure connection provided by SSH protocol. And it supports to write SSH client as well.

NOTE: ED25519 public key algorithm is now separated from hrr_rb_ssh. Please refer to [hrr_rb_ssh-ed25519](https://github.com/hirura/hrr_rb_ssh-ed25519).

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
    - [Requiring hrr\_rb\_ssh library](#requiring-hrr_rb_ssh-library)
    - [Logging](#logging)
    - [Writing standard SSH server](#writing-standard-ssh-server)
        - [Starting server application](#starting-server-application)
        - [Registering pre\-generated secret keys for server host key](#registering-pre-generated-secret-keys-for-server-host-key)
        - [Defining authentications](#defining-authentications)
            - [Single authentication](#single-authentication)
                - [Password authentication](#password-authentication)
                - [Publickey authentication](#publickey-authentication)
                - [Keyboard-interactive authentication](#keyboard-interactive-authentication)
                - [None authentication (NOT recomended)](#none-authentication-not-recomended)
            - [Multi\-step authentication](#multi-step-authentication)
            - [More flexible authentication](#more-flexible-authentication)
        - [Handling session channel requests](#handling-session-channel-requests)
            - [Reference request handlers](#reference-request-handlers)
            - [Custom request handlers](#custom-request-handlers)
        - [Defining preferred algorithms (optional)](#defining-preferred-algorithms-optional)
        - [Hiding and/or simulating local SSH version](#hiding-and-or-simulating-local-ssh-version)
    - [Writing SSH client (Experimental)](#writing-ssh-client-experimental)
        - [Starting SSH connection](#starting-ssh-connection)
        - [Executing remote commands](#executing-remote-commands)
            - [exec method](#exec-method)
            - [shell method](#shell-method)
            - [subsystem method](#subsystem-method)
    - [Demo](#demo)
- [Supported Features](#supported-features)
    - [Connection layer](#connection-layer)
    - [Authentication layer](#authentication-layer)
    - [Transport layer](#transport-layer)
- [Contributing](#contributing)
- [Code of Conduct](#code-of-conduct)
- [License](#license)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hrr_rb_ssh'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install hrr_rb_ssh
```

## Usage

### Requiring `hrr_rb_ssh` library

First of all, `hrr_rb_ssh` library needs to be loaded.

```ruby
require 'hrr_rb_ssh'
```

### Logging

__IMPORTANT__: DEBUG log level outputs all communications between local and remote in human-readable plain-text including password and any secret. Be careful to use logging.

The library provides logging functionality. To enable logging in the library, you are to give a `logger` to `Server.new` or `Client.new`.

```ruby
HrrRbSsh::Server.new options, logger: logger
```

or

```ruby
HrrRbSsh::Client.new target, options, logger: logger
```

Where, the `logger` variable can be an instance of standard Logger class or user-defined logger class. What the library requires for `logger` variable is that the `logger` instance responds to `#fatal`, `#error`, `#warn`, `#info` and `#debug` with the following syntax.

```ruby
logger.fatal(progname){ message }
logger.error(progname){ message }
logger.warn(progname){ message }
logger.info(progname){ message }
logger.debug(progname){ message }
```

For instance, `logger` variable can be prepared like below.

```ruby
logger = Logger.new STDOUT
logger.level = Logger::INFO
```

### Writing standard SSH server

#### Starting server application

The library is to run on a socket IO. To start SSH server, running a server IO and accepting a connection are required. The 10022 port number is just an example.

```ruby
options = Hash.new
server = TCPServer.new 10022
loop do
  Thread.new(server.accept) do |io|
    pid = fork do
      begin
        server = HrrRbSsh::Server.new options
        server.start io
      ensure
        io.close
      end
    end
    io.close
    Process.waitpid pid
  end
end
```

Where, an `options` variable is an instance of `Hash`, which has optional (or sometimes almost necessary) values.

#### Registering pre-generated secret keys for server host key

By default, server host keys are generated everytime the gem is loaded. To use pre-generated keys, it is possible to register the keys in HrrRbSsh::Transport through `options` variable. The secret key value must be PEM or DER format string. The below is an example of registering ecdsa-sha2-nistp256 secret key. The supported server host key algorithms are listed later in this document.

```ruby
options['transport_server_secret_host_keys'] = {}
options['transport_server_secret_host_keys']['ecdsa-sha2-nistp256'] = <<-'EOB'
-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIFFtGZHk6A8anZkLCJan9YBlB63uCIN/ZcQNCaJout8loAoGCCqGSM49
AwEHoUQDQgAEk8m548Xga+XGEmRx7P71xGlxCfgjPj3XVOw+fXPXRgA03a5yDJEp
OfeosJOO9twerD7pPhmXREkygblPsEXaVA==
-----END EC PRIVATE KEY-----
EOB
```

#### Defining authentications

By default, any authentications get failed. To allow users to login to the SSH service, at least one of the authentication methods must be defined and registered into the instance of HrrRbSsh::Authentication through `options` variable.

The library defines a sort of strategies to implement handling authentication.

##### Single authentication

Each authenticator returns `true` (or `HrrRbSsh::Authentication::SUCCESS`) or `false` (or `HrrRbSsh::Authentication::FAILURE`). When it is true, the user is accepted. When it is false, the user is not accepted and a subsequent authenticator is called.

###### Password authentication

Password authentication is the most simple way to allow users to login to the SSH service. Password authentication requires user-name and password.

To define a password authentication, the `HrrRbSsh::Authentication::Authenticator.new { |context| ... }` block is used. When the block returns `true`, then the authentication succeeded.

```ruby
auth_password = HrrRbSsh::Authentication::Authenticator.new { |context|
  user_and_pass = [
    ['user1',  'password1'],
    ['user2',  'password2'],
  ]
  user_and_pass.any? { |user, pass|
    context.verify user, pass
  }
}
options['authentication_password_authenticator'] = auth_password
```

The `context` variable in password authentication context provides the followings.

- `#username` : The username that a remote user tries to authenticate
- `#password` : The password that a remote user tries to authenticate
- `#variables` : A hash instance that is shared in each authenticator and subsequent session channel request handlers
- `#vars` : The same object that `#variables` returns
- `#verify(username, password)` : Returns `true` when username and password arguments match with the context's username and password. Or returns `false` when username and password arguments don't match.

###### Publickey authentication

The second one is public key authentication. Public key authentication requires user-name, public key algorithm name, and PEM or DER formed public key.

To define a public key authentication, the `HrrRbSsh::Authentication::Authenticator.new { |context| ... }` block is used as well.  When the block returns `true`, then the authentication succeeded as well. However, `context` variable behaves differently.

```ruby
auth_publickey = HrrRbSsh::Authentication::Authenticator.new { |context|
  username = ENV['USER']
  authorized_keys = HrrRbSsh::Compat::OpenSSH::AuthorizedKeys.new(File.read(File.join(Dir.home, '.ssh', 'authorized_keys')))
  authorized_keys.any?{ |public_key|
    context.verify username, public_key.algorithm_name, public_key.to_pem
  }
}
options['authentication_publickey_authenticator'] = auth_publickey
```

The `context` variable in public key authentication context provides the `#verify` method. The `#verify` method takes three arguments; username, public key algorithm name and PEM or DER formed public key.

And public keys that is in OpenSSH public key format is now available. To use OpenSSH public keys, it is easy to use $USER_HOME/.ssh/authorized_keys file.

###### Keyboard-interactive authentication

The third one is keyboard-interactive authentication. This is also known as challenge-response authentication.

To define a keyboard-interactive authentication, the `HrrRbSsh::Authentication::Authenticator.new { |context| ... }` block is used as well.  When the block returns `true`, then the authentication succeeded as well. However, `context` variable behaves differently.

```ruby
auth_keyboard_interactive = HrrRbSsh::Authentication::Authenticator.new { |context|
  user_name        = 'user1'
  req_name         = 'demo keyboard interactive authentication'
  req_instruction  = 'demo instruction'
  req_language_tag = ''
  req_prompts = [
    #[prompt[n], echo[n]]
    ['Password1: ', false],
    ['Password2: ', true],
  ]
  info_response = context.info_request req_name, req_instruction, req_language_tag, req_prompts
  context.username == user_name && info_response.responses == ['password1', 'password2']
}
options['authentication_keyboard_interactive_authenticator'] = auth_keyboard_interactive
```

The `context` variable in keyboard-interactive authentication context does NOT provides the `#verify` method. Instead, `#info_request` method is available. Since keyboard-interactive authentication has multiple times interactions between server and client, the values in responses needs to be verified respectively.

The `#info_request` method takes four arguments: name, instruction, language tag, and prompts. The name, instruction, and language tag can be empty string. The prompts needs to have at least one charactor for prompt message, and `true` or `false` value to specify whether echo back is enabled or not.

The responses are listed in the same order as request prompts.

###### None authentication (NOT recomended)

The last one is none authentication. None authentication is usually NOT used.

To define a none authentication, the `HrrRbSsh::Authentication::Authenticator.new { |context| ... }` block is used as well.  When the block returns `true`, then the authentication succeeded as well. However, `context` variable behaves differently.

```ruby
auth_none = HrrRbSsh::Authentication::Authenticator.new { |context|
  if context.username == 'user1'
    true
  else
    false
  end
}
options['authentication_none_authenticator'] = auth_none
```

In none authentication context, `context` variable provides the `#username` method.

##### Multi-step authentication

In this strategy that conbines single authentications, it is possible to implement multi-step authentication. In case that the combination is a publickey authentication method and a password authentication method, it is so-called two-factor authentication.

A return value of each authentication handler can be `HrrRbSsh::Authentication::PARTIAL_SUCCESS`. The value means that the authentication method returns success and another authenticatoin method is requested (i.e. the authentication method is deleted from the list of authentication that can continue, and then the server sends USERAUTH_FAILURE message with the updated list of authentication that can continue and partial success true). When all preferred authentication methods returns `PARTIAL_SUCCESS` (i.e. there is no more authentication that can continue), then the user is treated as authenticated.

```ruby
auth_preferred_authentication_methods = ["publickey", "password"]
auth_publickey = HrrRbSsh::Authentication::Authenticator.new { |context|
  is_verified = some_verification_method(context)
  if is_verified
    HrrRbSsh::Authentication::PARTIAL_SUCCESS
  else
    false
  end
}
auth_password = HrrRbSsh::Authentication::Authenticator.new { |context|
  is_verified = some_verification_method(context)
  if is_verified
    HrrRbSsh::Authentication::PARTIAL_SUCCESS
  else
    false
  end
}
options['authentication_preferred_authentication_methods'] = auth_preferred_authentication_methods
options['authentication_publickey_authenticator'] = auth_publickey
options['authentication_password_authenticator'] = auth_password
```

##### More flexible authentication

A `context` variable in an authenticator gives an access to remaining authentication methods that can continue. In this strategy, an implementer is able to control the order of authentication methods and to control which authentication methods are used for the user.

The below is an example. It is expected that any user must be verified by publickey and then another authentication is requested for the user accordingly.

```ruby
auth_preferred_authentication_methods = ['none']
auth_none = HrrRbSsh::Authentication::Authenticator.new{ |context|
  context.authentication_methods.push 'publickey'
  HrrRbSsh::Authentication::PARTIAL_SUCCESS
}
auth_publickey = HrrRbSsh::Authentication::Authenticator.new{ |context|
  if some_verification(context)
    case context.username
    when 'user1'
      context.authentiation_methods.push 'keyboard-interactive'
      HrrRbSsh::Authentication::PARTIAL_SUCCESS
    else
      false
    end
  else
    false
  end
}
auth_keyboard_interactive = HrrRbSsh::Authentication::Authenticator.new{ |context|
  if some_verification(context)
    true # or HrrRbSsh::Authentication::PARTIAL_SUCCESS; both will accept the user because remaining authentication method is only 'keyboard-interactive' in this case
  else
    false
  end
}
options['authentication_preferred_authentication_methods'] = auth_preferred_authentication_methods
options['authentication_none_authenticator'] = auth_none
options['authentication_publickey_authenticator'] = auth_publickey
options['authentication_keyboard_interactive_authenticator'] = auth_keyboard_interactive
```

#### Handling session channel requests

By default, any channel requests belonging to session channel are implicitly ignored. To handle the requests, defining request handlers are required.

##### Reference request handlers

There are pre-implemented request handlers available for reference as below.

```ruby
options['connection_channel_request_pty_req']       = HrrRbSsh::Connection::RequestHandler::ReferencePtyReqRequestHandler.new
options['connection_channel_request_env']           = HrrRbSsh::Connection::RequestHandler::ReferenceEnvRequestHandler.new
options['connection_channel_request_shell']         = HrrRbSsh::Connection::RequestHandler::ReferenceShellRequestHandler.new
options['connection_channel_request_exec']          = HrrRbSsh::Connection::RequestHandler::ReferenceExecRequestHandler.new
options['connection_channel_request_window_change'] = HrrRbSsh::Connection::RequestHandler::ReferenceWindowChangeRequestHandler.new
```

##### Custom request handlers

It is also possible to define customized request handlers. For instance, echo server can be implemented very easily as below. In this case, echo server works instead of shell and PTY-req and env requests are undefined.

```ruby
conn_echo = HrrRbSsh::Connection::RequestHandler.new { |context|
  context.chain_proc { |chain|
    begin
      loop do
        buf = context.io[0].readpartial(10240)
        break if buf.include?(0x04.chr) # break if ^D
        context.io[1].write buf
      end
      exitstatus = 0
    rescue => e
      logger.error([e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join)
      exitstatus = 1
    end
    exitstatus
  }
}
options['connection_channel_request_shell'] = conn_echo
```

In `HrrRbSsh::Connection::RequestHandler.new` block, context variable basically provides the followings.

- `#io => [in, out, err]` : `in` is readable and read data is sent by remote. `out` and `err` are writable. `out` is for standard output and written data is sent as channel data. `err` is for standard error and written data is sent as channel extended data.
- `#chain_proc => {|chain| ... }` : When a session channel is opened, a background thread is started and is waitng for a chained block registered. This `#chain_proc` is used to define how to handle subsequent communications between local and remote. The `chain` variable provides `#call_next` method. In `#proc_chain` block, it is possible to call subsequent block that is defined in another request handler. For instance, shell request must called after pty-req request. The `chain` in pty-req request handler's `#chain_proc` calls `#next_proc` and then subsequent shell request handler's `#chain_proc` will be called.
- `#close_session` : In most cases, input and output between a client and the server is handled in `#chain_proc` and closing the `#chain_proc` block will lead closing the underlying session channel. This means that to close the underlying session channel it is required to write at least one `#chain_proc` block. If it is not required to use `#chain_proc` block or is required to close the underlying session channel from outside of `#chain_proc` block, `#close_session` can be used. The `#close_session` will close the background thread that calls `#chain_proc` blocks.
- `#variables => Hash` : A hash instance that is passed from authenticator and is shared in subsequent session channel request handlers
- `#vars` : The same object that `#variables` returns

And request handler's `context` variable also provides additional methods based on request type. See `lib/hrr_rb_ssh/connection/channel/channel_type/session/request_type/<request type>/context.rb`.

#### Defining preferred algorithms (optional)

Preferred encryption, server-host-key, KEX and compression algorithms can be selected and defined.

```ruby
options['transport_preferred_encryption_algorithms']      = %w(aes256-ctr aes128-cbc)
options['transport_preferred_server_host_key_algorithms'] = %w(ecdsa-sha2-nistp256 ssh-rsa)
options['transport_preferred_kex_algorithms']             = %w(ecdh-sha2-nistp256 diffie-hellman-group14-sha1)
options['transport_preferred_mac_algorithms']             = %w(hmac-sha2-256 hmac-sha1)
options['transport_preferred_compression_algorithms']     = %w(none)
```

Supported algorithms can be got with each algorithm class's `#list_supported` method, and default preferred algorithms can be got with each algorithm class's `#list_preferred` method.

Outputs of `#list_preferred` method are ordered as preferred; i.e. the name listed at head is used as most preferred, and the name listed at tail is used as non-preferred.

```ruby
p HrrRbSsh::Transport::EncryptionAlgorithm.list_supported
# => ["none", "3des-cbc", "blowfish-cbc", "aes128-cbc", "aes192-cbc", "aes256-cbc", "arcfour", "cast128-cbc", "aes128-ctr", "aes192-ctr", "aes256-ctr"]
p HrrRbSsh::Transport::EncryptionAlgorithm.list_preferred
# => ["aes128-ctr", "aes192-ctr", "aes256-ctr", "aes128-cbc", "3des-cbc", "blowfish-cbc", "cast128-cbc", "aes192-cbc", "aes256-cbc", "arcfour"]

p HrrRbSsh::Transport::ServerHostKeyAlgorithm.list_supported
# => ["ssh-dss", "ssh-rsa", "ecdsa-sha2-nistp256", "ecdsa-sha2-nistp384", "ecdsa-sha2-nistp521"]
p HrrRbSsh::Transport::ServerHostKeyAlgorithm.list_preferred
# => ["ecdsa-sha2-nistp521", "ecdsa-sha2-nistp384", "ecdsa-sha2-nistp256", "ssh-rsa", "ssh-dss"]

p HrrRbSsh::Transport::KexAlgorithm.list_supported
# => ["diffie-hellman-group1-sha1", "diffie-hellman-group14-sha1", "diffie-hellman-group-exchange-sha1", "diffie-hellman-group-exchange-sha256", "diffie-hellman-group14-sha256", "diffie-hellman-group15-sha512", "diffie-hellman-group16-sha512", "diffie-hellman-group17-sha512", "diffie-hellman-group18-sha512", "ecdh-sha2-nistp256", "ecdh-sha2-nistp384", "ecdh-sha2-nistp521"]
p HrrRbSsh::Transport::KexAlgorithm.list_preferred
# => ["ecdh-sha2-nistp521", "ecdh-sha2-nistp384", "ecdh-sha2-nistp256", "diffie-hellman-group18-sha512", "diffie-hellman-group17-sha512", "diffie-hellman-group16-sha512", "diffie-hellman-group15-sha512", "diffie-hellman-group14-sha256", "diffie-hellman-group-exchange-sha256", "diffie-hellman-group-exchange-sha1", "diffie-hellman-group14-sha1", "diffie-hellman-group1-sha1"]

p HrrRbSsh::Transport::MacAlgorithm.list_supported
# => ["none", "hmac-sha1", "hmac-sha1-96", "hmac-md5", "hmac-md5-96", "hmac-sha2-256", "hmac-sha2-512"]
p HrrRbSsh::Transport::MacAlgorithm.list_preferred
# => ["hmac-sha2-512", "hmac-sha2-256", "hmac-sha1", "hmac-md5", "hmac-sha1-96", "hmac-md5-96"]

p HrrRbSsh::Transport::CompressionAlgorithm.list_supported
# => ["none", "zlib"]
p HrrRbSsh::Transport::CompressionAlgorithm.list_preferred
# => ["none", "zlib"]
```

#### Hiding and/or simulating local SSH version

By default, hrr_rb_ssh sends `SSH-2.0-HrrRbSsh-#{VERSION}` string at initial negotiation with remote peer. To address security concerns, it is possible to replace the version string.

```ruby
# Hiding version
options['local_version'] = "SSH-2.0-HrrRbSsh"

# Simulating OpenSSH
options['local_version'] = "SSH-2.0-OpenSSH_x.x"

# Simulating OpenSSH and hiding version
options['local_version'] = "SSH-2.0-OpenSSH"
```

Please note that the beginning of the string must be `SSH-2.0-`. Otherwise SSH 2.0 remote peer cannot continue negotiation with the local peer.

### Writing SSH client (Experimental)

#### Starting SSH connection

The client mode can be started with `HrrRbSsh::Client.start`. The method takes `target` and `options` arguments. The `target` that the SSH client connects to can be one of:

- (IO) An io that is open for input and output
- (Array) An array of the target host address or host name and its service port number
- (String) The target host address or host name; in this case the target service port number will be 22

And the `options` contains various parameters for the SSH connection. At least `username` key must be set in the `options`. Also at least one of `password`, `publickey`, or `keyboard-interactive` needs to be set for authentication instead of authenticators that are used in server mode. Also as similar to server mode, it is possible to specify preferred transport algorithms and preferred authentication methods with the same keywords.

```ruby
target = ['remotehost', 22]
options = {
  username: 'user1',
  password: 'password1',
  publickey: ['ssh-rsa', "/home/user1/.ssh/id_rsa")],
  authentication_preferred_authentication_methods = ['publickey', 'password'],
}
HrrRbSsh::Client.start(target, options) do |conn|
  # Do something here
  # For instance: conn.exec "command"
end
```

#### Executing remote commands

There are some methods supported in client mode. The methods works as a receiver of `conn` block variable.

##### exec method

The `exec` and `exec!` methods execute command on a remote host. Both takes a command argument that is executed in the remote host. And they can take optional `pty` and `env` arguments. When `pty: true` is set, then the command will be executed on a pseudo-TTY. When `env: {'key' => 'value'}` is set, then the environmental variables are set before the command is executed.

The `exec!` method returns `[stdout, stderr]` outputs. Once the command is executed and the outputs are completed, then the method returns the value.

```ruby
conn.exec! "command" # => [stdout, stderr]
```

On the other hand, `exec` method takes block like the below example and returns exit status of the command. When the command is executed and the outputs and reading them are finished, then `io_out` and `io_err` return EOF.

```ruby
conn.exec "command" do |io_in, io_out, io_err|
  # Do something here
end
```

##### shell method

The `shell` method provides a shell access on a remote host. As similar to `exec` method, it takes block and its block variable is also `io_in, io_out, io_err`. `shell` is always on pseudo-TTY, so it doesn't take `pty` optional argument. It takes `env` optional argument. Exiting shell will leads `io_out` and `io_err` EOF.

```ruby
conn.shell do |io_in, io_out, io_err|
  # Do something here
end
```

##### subsystem method

The `subsystem` method is to start a subsystem on a remote host. The method takes a subsystem name argument and a block. Its block variable is also `io_in, io_out, io_err`. `subsystem` doesn't take `pty` nor `env` optional argument.

```ruby
conn.subsystem("echo") do |io_in, io_out, io_err|
  # Do something here
end
```

### Demo

The `demo/server.rb` shows a good example on how to use the hrr_rb_ssh library in SSH server mode. And the `demo/client.rb` shows an example on how to use the hrr_rb_ssh library in SSH client mode.

## Supported Features

The following features are currently supported.

### Connection layer

- Session channel
    - Shell (PTY-req, env, shell, window-change) request
    - Exec request
    - Subsystem request
- Local port forwarding (direct-tcpip channel)
- Remote port forwarding (tcpip-forward global request and forwarded-tcpip channel)

### Authentication layer

- None authentication
- Password authentication
- Public key authentication
    - ssh-dss
    - ssh-rsa
    - ecdsa-sha2-nistp256
    - ecdsa-sha2-nistp384
    - ecdsa-sha2-nistp521
- Keyboard interactive (generic interactive / challenge response) authentication

### Transport layer

- Encryption algorithm
    - none
    - 3des-cbc
    - blowfish-cbc
    - aes128-cbc
    - aes192-cbc
    - aes256-cbc
    - arcfour
    - cast128-cbc
    - aes128-ctr
    - aes192-ctr
    - aes256-ctr
- Server host key algorithm
    - ssh-dss
    - ssh-rsa
    - ecdsa-sha2-nistp256
    - ecdsa-sha2-nistp384
    - ecdsa-sha2-nistp521
- Kex algorithm
    - diffie-hellman-group1-sha1
    - diffie-hellman-group14-sha1
    - diffie-hellman-group-exchange-sha1
    - diffie-hellman-group-exchange-sha256
    - diffie-hellman-group14-sha256
    - diffie-hellman-group15-sha512
    - diffie-hellman-group16-sha512
    - diffie-hellman-group17-sha512
    - diffie-hellman-group18-sha512
    - ecdh-sha2-nistp256
    - ecdh-sha2-nistp384
    - ecdh-sha2-nistp521
- Mac algorithm
    - none
    - hmac-sha1
    - hmac-sha1-96
    - hmac-md5
    - hmac-md5-96
    - hmac-sha2-256
    - hmac-sha2-512
- Compression algorithm
    - none
    - zlib

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hirura/hrr_rb_ssh. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the HrrRbSsh project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/hirura/hrr_rb_ssh/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [Apache License 2.0](https://opensource.org/licenses/Apache-2.0).
