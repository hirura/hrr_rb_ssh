# HrrRbSsh

[![Build Status](https://travis-ci.org/hirura/hrr_rb_ssh.svg?branch=master)](https://travis-ci.org/hirura/hrr_rb_ssh)
[![Maintainability](https://api.codeclimate.com/v1/badges/f5dfdb97d72f24ca5939/maintainability)](https://codeclimate.com/github/hirura/hrr_rb_ssh/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/f5dfdb97d72f24ca5939/test_coverage)](https://codeclimate.com/github/hirura/hrr_rb_ssh/test_coverage)
[![Gem Version](https://badge.fury.io/rb/hrr_rb_ssh.svg)](https://badge.fury.io/rb/hrr_rb_ssh)

hrr_rb_ssh is a pure Ruby SSH 2.0 server implementation.

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

### Writing standard SSH server

#### Requiring `hrr_rb_ssh` library

First of all, `hrr_rb_ssh` library needs to be loaded.

```ruby
require 'hrr_rb_ssh'
```

#### Starting server application

The library is to run on a socket IO. To start SSH server, running a server IO and accepting a connection are required. The 10022 port number is just an example.

```ruby
options = Hash.new
server = TCPServer.new 10022
while true
  t = Thread.new(server.accept) do |io|
    tran = HrrRbSsh::Transport.new      io, HrrRbSsh::Transport::Mode::SERVER, options
    auth = HrrRbSsh::Authentication.new tran, options
    conn = HrrRbSsh::Connection.new     auth, options
    conn.start
    io.close
  end
end
```

Where, an `options` variable is an instance of `Hash`, which has optional (or sometimes almost necessary) values.

#### Logging

__IMPORTANT__: DEBUG log level outputs all communications between local and remote in human-readable plain-text including password and any secret. Be careful to use logging.

The library provides logging functionality. To enable logging of the library, you are to initialize `HrrRbSsh::Logger` class.

```ruby
HrrRbSsh::Logger.initialize logger
```

Where, the `logger` variable can be an instance of standard Logger class or user-defined logger class. What `HrrRbSsh::Logger` class requires for `logger` variable is that the `logger` instance responds to `#fatal`, `#error`, `#warn`, `#info` and `#debug`.

For instance, `logger` variable can be prepared like below.

```ruby
logger = Logger.new STDOUT
logger.level = Logger::INFO
```

To disable logging, you can un-initialize `HrrRbSsh::Logger`.

```ruby
HrrRbSsh::Logger.uninitialize
```

#### Defining authentications

By default, any authentications get failed. To allow users to login to the SSH service, at least one of the authentication methods must be defined and registered into the instance of HrrRbSsh::Authentication through `options` variable.

##### Password authentication

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
- `#verify(username, password)` : Returns `true` when username and password arguments match with the context's username and password. Or returns `false` when username and password arguments don't match.

##### Publickey authentication

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

##### None authentication (NOT recomended)

The third one is none authentication. None authentication is usually NOT used.

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
  context.io[2].close
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
    ensure
      context.io[1].close
    end
    exitstatus
  }
}
options['connection_channel_request_shell'] = conn_echo
```

In `HrrRbSsh::Connection::RequestHandler.new` block, context variable basically provides the followings.

- `#io => [in, out, err]` : `in` is readable and read data is sent by remote. `out` and `err` are writable. `out` is for standard output and written data is sent as channel data. `err` is for standard error and written data is sent as channel extended data.
- `#chain_proc => {|chain| ... }` : When a session channel is opened, a background thread is started and is waitng for a chaned block registered. This `#chain_proc` is used to define how to handle subsequent communications between local and remote. The `chain` variable provides `#call_next` method. In `#proc_chain` block, it is possible to call subsequent block that is defined in another request handler. For instance, shell request must called after pty-req request. The `chain` in pty-req request handler's `#chain_proc` calls `#next_proc` and then subsequent shell request handler's `#chain_proc` will be called.

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

p HrrRbSsh::Transport::EncryptionAlgorithm.list_supported
# => ["none", "3des-cbc", "blowfish-cbc", "aes128-cbc", "aes192-cbc", "aes256-cbc", "arcfour", "cast128-cbc", "aes128-ctr", "aes192-ctr", "aes256-ctr"]
HrrRbSsh::Transport::ServerHostKeyAlgorithm.list_preferred
# => ["ecdsa-sha2-nistp521", "ecdsa-sha2-nistp384", "ecdsa-sha2-nistp256", "ssh-rsa", "ssh-dss"]

p HrrRbSsh::Transport::ServerHostKeyAlgorithm.list_supported
# => ["ssh-dss", "ssh-rsa", "ecdsa-sha2-nistp256", "ecdsa-sha2-nistp384", "ecdsa-sha2-nistp521"]
p HrrRbSsh::Transport::KexAlgorithm.list_preferred
# => ["ecdh-sha2-nistp521", "ecdh-sha2-nistp384", "ecdh-sha2-nistp256", "diffie-hellman-group18-sha512", "diffie-hellman-group17-sha512", "diffie-hellman-group16-sha512", "diffie-hellman-group15-sha512", "diffie-hellman-group14-sha256", "diffie-hellman-group-exchange-sha256", "diffie-hellman-group-exchange-sha1", "diffie-hellman-group14-sha1", "diffie-hellman-group1-sha1"]
 
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

### Demo

The `demo/server.rb` shows a good example on how to use the hrr_rb_ssh library in SSH server mode.

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

Everyone interacting in the HrrRbSsh project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/hirura/hrr_rb_ssh/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [Apache License 2.0](https://opensource.org/licenses/Apache-2.0).
