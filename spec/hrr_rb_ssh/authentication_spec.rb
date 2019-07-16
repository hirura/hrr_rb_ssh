# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Authentication do
  describe '::SERVICE_NAME' do
    let(:service_name){ 'ssh-userauth' }

    it "is defined" do
      expect( described_class::SERVICE_NAME ).to eq service_name
    end
  end

  describe '#new' do
    let(:io){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:options){ Hash.new }

    describe "when mode is server" do
      let(:mode){ HrrRbSsh::Mode::SERVER }

      it "can take one argument: transport" do
        expect { described_class.new(transport, mode) }.not_to raise_error
      end

      it "can take two arguments: transport and options" do
        expect { described_class.new(transport, mode, options) }.not_to raise_error
      end

      it "registeres ::SERVICE_NAME in transport" do
        expect {
          described_class.new transport, mode
        }.to change {
          transport.instance_variable_get(:@acceptable_services)
        }.from([]).to([described_class::SERVICE_NAME])
      end
    end

    describe "when mode is client" do
      let(:mode){ HrrRbSsh::Mode::CLIENT }

      it "can take one argument: transport" do
        expect { described_class.new(transport, mode) }.not_to raise_error
      end

      it "can take two arguments: transport and options" do
        expect { described_class.new(transport, mode, options) }.not_to raise_error
      end
    end
  end

  describe '#send' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ described_class.new(transport, mode) }
    let(:payload){ "testing" }

    context "when transport is not closed" do
      it "sends payload" do
        expect(transport).to receive(:send).with(payload).once
        authentication.send payload
      end
    end

    context "when transport is closed" do
      it "raises Error::ClosedAuthentication" do
        expect(transport).to receive(:send).with(payload).and_raise(HrrRbSsh::Error::ClosedTransport).once
        expect { authentication.send payload }.to raise_error HrrRbSsh::Error::ClosedAuthentication
      end
    end
  end

  describe '#receive' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ described_class.new(transport, mode) }
    let(:payload){ "testing" }

    context "when transport is not closed" do
      it "receives payload" do
        expect(transport).to receive(:receive).with(no_args).and_return(payload).once
        expect(authentication.receive).to eq payload
      end
    end

    context "when transport is closed" do
      it "raises Error::ClosedAuthentication" do
        expect(transport).to receive(:receive).with(no_args).and_raise(HrrRbSsh::Error::ClosedTransport).once
        expect { authentication.receive }.to raise_error HrrRbSsh::Error::ClosedAuthentication
      end
    end
  end

  describe '#start' do
    let(:io){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ described_class.new(transport, mode) }

    describe "when mode is server" do
      let(:mode){ HrrRbSsh::Mode::SERVER }

      it "calls transport.start and respond_to_authentication methods" do
        expect( transport ).to receive(:start).with(no_args).once
        expect( authentication ).to receive(:respond_to_authentication).with(no_args).once

        authentication.start
      end
    end

    describe "when mode is client" do
      let(:mode){ HrrRbSsh::Mode::CLIENT }

      it "calls transport.start and request_authentication methods" do
        expect( transport ).to receive(:start).with(no_args).once
        expect( authentication ).to receive(:request_authentication).with(no_args).once

        authentication.start
      end
    end
  end

  describe '#close' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ described_class.new(transport, mode) }

    context "when not closed" do
      before :example do
        authentication.instance_variable_set('@closed', false)
      end

      it "closes self" do
        authentication.close
        expect(authentication.closed?).to be true
      end

      it "calls transport.close" do
        expect(transport).to receive(:close).with(no_args).once
        authentication.close
      end
    end
  end

  describe '#closed?' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ described_class.new(transport, mode) }

    context "when not closed" do
      before :example do
        authentication.instance_variable_set('@closed', false)
      end

      it "returns false" do
        expect(authentication.closed?).to be false
      end
    end

    context "when closed" do
      before :example do
        authentication.instance_variable_set('@closed', true)
      end

      it "returns true" do
        expect(authentication.closed?).to be true
      end
    end
  end

  describe '#respond_to_authentication' do
    let(:io){ 'dummy' }
    let(:mode){ HrrRbSsh::Mode::SERVER }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ described_class.new(transport, mode, options) }
    let(:userauth_failure_message){
      {
        :'message number'                    => HrrRbSsh::Message::SSH_MSG_USERAUTH_FAILURE::VALUE,
        :'authentications that can continue' => preferred_authentication_methods,
        :'partial success'                   => partial_success,
      }
    }
    let(:userauth_failure_payload){
      HrrRbSsh::Message::SSH_MSG_USERAUTH_FAILURE.encode userauth_failure_message
    }
    let(:userauth_failure_message_2){
      {
        :'message number'                    => HrrRbSsh::Message::SSH_MSG_USERAUTH_FAILURE::VALUE,
        :'authentications that can continue' => preferred_authentication_methods_2,
        :'partial success'                   => partial_success_2,
      }
    }
    let(:userauth_failure_payload_2){
      HrrRbSsh::Message::SSH_MSG_USERAUTH_FAILURE.encode userauth_failure_message_2
    }
    let(:userauth_success_message){
      {
        :'message number' => HrrRbSsh::Message::SSH_MSG_USERAUTH_SUCCESS::VALUE,
      }
    }
    let(:userauth_success_payload){
      HrrRbSsh::Message::SSH_MSG_USERAUTH_SUCCESS.encode userauth_success_message
    }
    let(:username){ "username" }

    context "when accept none method" do
      let(:options){
        {
          'authentication_none_authenticator' => HrrRbSsh::Authentication::Authenticator.new { true },
        }
      }
      let(:userauth_request_with_none_method_message){
        {
          :'message number' => HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
          :'user name'      => username,
          :'service name'   => "ssh-connection",
          :'method name'    => "none",
        }
      }
      let(:userauth_request_with_none_method_payload){
        HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST.encode userauth_request_with_none_method_message
      }

      it "sends userauth success message for none method, and will return authenticated username" do
        expect( transport ).to receive(:receive).with(no_args).and_return(userauth_request_with_none_method_payload).once
        expect( transport ).to receive(:send).with(userauth_success_payload).once

        authentication.respond_to_authentication

        expect( authentication.closed? ).to be false
        expect( authentication.username ).to eq username
      end
    end

    context "when accept password method after none method" do
      let(:options){
        {
          'authentication_none_authenticator' => HrrRbSsh::Authentication::Authenticator.new { false },
          'authentication_password_authenticator' => HrrRbSsh::Authentication::Authenticator.new { |context| context.verify 'username', 'password' },
        }
      }
      let(:userauth_request_with_none_method_message){
        {
          :'message number' => HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
          :'user name'      => username,
          :'service name'   => "ssh-connection",
          :'method name'    => "none",
        }
      }
      let(:userauth_request_with_none_method_payload){
        HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST.encode userauth_request_with_none_method_message
      }
      let(:userauth_request_with_password_method_message){
        {
          :'message number'     => HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
          :'user name'          => username,
          :'service name'       => "ssh-connection",
          :'method name'        => "password",
          :'FALSE'              => false,
          :'plaintext password' => "password"
        }
      }
      let(:userauth_request_with_password_method_payload){
        HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST.encode userauth_request_with_password_method_message
      }
      let(:userauth_requests){
        [
          userauth_request_with_none_method_payload,
          userauth_request_with_password_method_payload,
        ]
      }
      let(:preferred_authentication_methods){
        HrrRbSsh::Authentication::Method.list_preferred
      }
      let(:partial_success){
        false
      }

      it "sends userauth success message for password method after userauth failure message for none method, and will return authenticated username" do
        expect( transport ).to receive(:receive).with(no_args).and_return(*userauth_requests).twice
        expect( transport ).to receive(:send).with(userauth_failure_payload).once
        expect( transport ).to receive(:send).with(userauth_success_payload).once

        authentication.respond_to_authentication

        expect( authentication.closed? ).to be false
        expect( authentication.username ).to eq username
      end
    end

    context "when accept public key method with no signature, and then with sigunature" do
      let(:options){
        {
          'authentication_publickey_authenticator' => HrrRbSsh::Authentication::Authenticator.new { |context| true },
        }
      }
      let(:userauth_request_with_publickey_method_with_no_signature_message){
        {
          :'message number'            => HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
          :'user name'                 => username,
          :'service name'              => "ssh-connection",
          :'method name'               => "publickey",
          :'with signature'            => false,
          :'public key algorithm name' => "ssh-rsa",
          :'public key blob'           => "dummy",
        }
      }
      let(:userauth_request_with_publickey_method_with_no_signature_payload){
        HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST.encode userauth_request_with_publickey_method_with_no_signature_message
      }
      let(:userauth_request_with_publickey_method_with_signature_message){
        {
          :'message number'            => HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
          :'user name'                 => username,
          :'service name'              => "ssh-connection",
          :'method name'               => "publickey",
          :'with signature'            => true,
          :'public key algorithm name' => "ssh-rsa",
          :'public key blob'           => "dummy",
          :'signature'                 => "dummy",
        }
      }
      let(:userauth_request_with_publickey_method_with_signature_payload){
        HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST.encode userauth_request_with_publickey_method_with_signature_message
      }
      let(:userauth_pk_ok_message){
        {
          :'message number'                             => HrrRbSsh::Message::SSH_MSG_USERAUTH_PK_OK::VALUE,
          :'public key algorithm name from the request' => "ssh-rsa",
          :'public key blob from the request'           => "dummy",
        }
      }
      let(:userauth_pk_ok_payload){
        HrrRbSsh::Message::SSH_MSG_USERAUTH_PK_OK.encode userauth_pk_ok_message
      }
      let(:userauth_requests){
        [
          userauth_request_with_publickey_method_with_no_signature_payload,
          userauth_request_with_publickey_method_with_signature_payload,
        ]
      }

      it "sends userauth success message for publickey method with signature after userauth pk ok message for no signature message, and will return authenticated username" do
        expect( transport ).to receive(:receive).with(no_args).and_return(*userauth_requests).twice
        expect( transport ).to receive(:send).with(userauth_pk_ok_payload).once
        expect( transport ).to receive(:send).with(userauth_success_payload).once

        authentication.respond_to_authentication

        expect( authentication.closed? ).to be false
        expect( authentication.username ).to eq username
      end
    end

    context "when password method is partially success after none method is partially success" do
      let(:options){
        {
          'authentication_none_authenticator' => HrrRbSsh::Authentication::Authenticator.new { HrrRbSsh::Authentication::PARTIAL_SUCCESS },
          'authentication_password_authenticator' => HrrRbSsh::Authentication::Authenticator.new { HrrRbSsh::Authentication::PARTIAL_SUCCESS },
          'authentication_preferred_authentication_methods' => preferred_authentication_methods,
        }
      }
      let(:userauth_request_with_none_method_message){
        {
          :'message number' => HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
          :'user name'      => username,
          :'service name'   => "ssh-connection",
          :'method name'    => "none",
        }
      }
      let(:userauth_request_with_none_method_payload){
        HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST.encode userauth_request_with_none_method_message
      }
      let(:userauth_request_with_password_method_message){
        {
          :'message number'     => HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
          :'user name'          => username,
          :'service name'       => "ssh-connection",
          :'method name'        => "password",
          :'FALSE'              => false,
          :'plaintext password' => "password"
        }
      }
      let(:userauth_request_with_password_method_payload){
        HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST.encode userauth_request_with_password_method_message
      }
      let(:userauth_requests){
        [
          userauth_request_with_none_method_payload,
          userauth_request_with_password_method_payload,
        ]
      }
      let(:partial_success_2){ true }

      let(:preferred_authentication_methods){
        [
          "none",
          "password",
        ]
      }
      let(:preferred_authentication_methods_2){
        [
          "password",
        ]
      }

      it "sends userauth success message for password method after userauth failure message with partial success for none method, and will return authenticated username" do
        expect( transport ).to receive(:receive).with(no_args).and_return(*userauth_requests).twice
        expect( transport ).to receive(:send).with(userauth_failure_payload_2).once
        expect( transport ).to receive(:send).with(userauth_success_payload).once

        authentication.respond_to_authentication

        expect( authentication.closed? ).to be false
        expect( authentication.username ).to eq username
      end
    end

    context "when adding another authentication method and return partial success" do
      let(:options){
        {
          'authentication_none_authenticator' => HrrRbSsh::Authentication::Authenticator.new { |context|
            context.authentication_methods.push 'password'
            HrrRbSsh::Authentication::PARTIAL_SUCCESS
          },
          'authentication_password_authenticator' => HrrRbSsh::Authentication::Authenticator.new { |context|
            HrrRbSsh::Authentication::PARTIAL_SUCCESS
          },
          'authentication_preferred_authentication_methods' => preferred_authentication_methods,
        }
      }
      let(:userauth_request_with_none_method_message){
        {
          :'message number' => HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
          :'user name'      => username,
          :'service name'   => "ssh-connection",
          :'method name'    => "none",
        }
      }
      let(:userauth_request_with_none_method_payload){
        HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST.encode userauth_request_with_none_method_message
      }
      let(:userauth_request_with_password_method_message){
        {
          :'message number'     => HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
          :'user name'          => username,
          :'service name'       => "ssh-connection",
          :'method name'        => "password",
          :'FALSE'              => false,
          :'plaintext password' => "password"
        }
      }
      let(:userauth_request_with_password_method_payload){
        HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST.encode userauth_request_with_password_method_message
      }
      let(:userauth_requests){
        [
          userauth_request_with_none_method_payload,
          userauth_request_with_password_method_payload,
        ]
      }
      let(:partial_success_2){ true }

      let(:preferred_authentication_methods){
        [
          "none",
        ]
      }
      let(:preferred_authentication_methods_2){
        [
          "password",
        ]
      }

      it "sends userauth success message for password method after userauth failure message with partial success for none method, and will return authenticated username" do
        expect( transport ).to receive(:receive).with(no_args).and_return(*userauth_requests).twice
        expect( transport ).to receive(:send).with(userauth_failure_payload_2).once
        expect( transport ).to receive(:send).with(userauth_success_payload).once

        authentication.respond_to_authentication

        expect( authentication.closed? ).to be false
        expect( authentication.username ).to eq username
      end
    end

    context "when receives not userauth request" do
      let(:options){ {} }
      let(:not_userauth_request_message){
        {
          :'NOT_USERAUTH_REQUEST' => 123,
        }
      }
      let(:not_userauth_request_payload){
        [
          HrrRbSsh::DataType::Byte.encode(not_userauth_request_message.values[0]),
        ].join
      }

      it "sends userauth failure message and raise error" do
        expect( transport ).to receive(:receive).with(no_args).and_return(not_userauth_request_payload).once

        expect { authentication.respond_to_authentication }.to raise_error RuntimeError

        expect( authentication.closed? ).to be true
      end
    end
  end

  describe '#request_authentication' do
    let(:io){ 'dummy' }
    let(:mode){ HrrRbSsh::Mode::CLIENT }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ described_class.new(transport, mode, options) }
    let(:userauth_failure_message){
      {
        :'message number'                    => HrrRbSsh::Message::SSH_MSG_USERAUTH_FAILURE::VALUE,
        :'authentications that can continue' => authentications_that_can_continue,
        :'partial success'                   => partial_success,
      }
    }
    let(:userauth_failure_payload){
      HrrRbSsh::Message::SSH_MSG_USERAUTH_FAILURE.encode userauth_failure_message
    }
    let(:userauth_success_message){
      {
        :'message number' => HrrRbSsh::Message::SSH_MSG_USERAUTH_SUCCESS::VALUE,
      }
    }
    let(:userauth_success_payload){
      HrrRbSsh::Message::SSH_MSG_USERAUTH_SUCCESS.encode userauth_success_message
    }
    let(:username){ "username" }

    context "when preferred_authentication_methods has no methods" do
      let(:options){
        {
          'username' => username,
          'authentication_preferred_authentication_methods' => [],
        }
      }
      let(:userauth_request_with_none_method_message){
        {
          :'message number' => HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
          :'user name'      => username,
          :'service name'   => "ssh-connection",
          :'method name'    => "none",
        }
      }
      let(:userauth_request_with_none_method_payload){
        HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST.encode userauth_request_with_none_method_message
      }

      context "when success" do
        it "sends userauth request message for none method, and will return authenticated username" do
          expect( transport ).to receive(:send).with(userauth_request_with_none_method_payload).once
          expect( transport ).to receive(:receive).with(no_args).and_return(userauth_success_payload).once

          authentication.request_authentication

          expect( authentication.closed? ).to be false
          expect( authentication.username ).to eq username
        end
      end

      context "when failure" do
        let(:authentications_that_can_continue){
          ['password', 'publickey', 'keyboard-interactive']
        }
        let(:partial_success){
          false
        }

        it "sends userauth request message for none method, and is closed" do
          expect( transport ).to receive(:send).with(userauth_request_with_none_method_payload).once
          expect( transport ).to receive(:receive).with(no_args).and_return(userauth_failure_payload).once

          expect { authentication.request_authentication }.to raise_error

          expect( authentication.closed? ).to be true
        end
      end
    end

    context "when preferred_authentication_methods has password method" do
      let(:options){
        {
          'username' => username,
          'authentication_preferred_authentication_methods' => ['password'],
          'client_authentication_password' => "password",
        }
      }
      let(:userauth_request_with_none_method_message){
        {
          :'message number' => HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
          :'user name'      => username,
          :'service name'   => "ssh-connection",
          :'method name'    => "none",
        }
      }
      let(:userauth_request_with_none_method_payload){
        HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST.encode userauth_request_with_none_method_message
      }
      let(:userauth_request_with_password_method_message){
        {
          :'message number'     => HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
          :'user name'          => username,
          :'service name'       => "ssh-connection",
          :'method name'        => "password",
          :'FALSE'              => false,
          :'plaintext password' => "password"
        }
      }
      let(:userauth_request_with_password_method_payload){
        HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST.encode userauth_request_with_password_method_message
      }
      let(:authentications_that_can_continue){
        ['password', 'publickey', 'keyboard-interactive']
      }
      let(:partial_success){
        false
      }

      it "sends userauth request message for password method and it is accepted after userauth request message for none method, and will return authenticated username" do
        expect( transport ).to receive(:send).with(userauth_request_with_none_method_payload).once
        expect( transport ).to receive(:send).with(userauth_request_with_password_method_payload).once
        expect( transport ).to receive(:receive).with(no_args).and_return(userauth_failure_payload, userauth_success_payload).twice

        authentication.request_authentication

        expect( authentication.closed? ).to be false
        expect( authentication.username ).to eq username
      end
    end

    context "when preferred_authentication_methods has password and keyboard-interactive methods, and password authentication response is partial success" do
      let(:options){
        {
          'username' => username,
          'authentication_preferred_authentication_methods' => ['password', 'keyboard-interactive'],
          'client_authentication_password' => "password",
          'client_authentication_keyboard_interactive' => ["password1", "password1"],
        }
      }
      let(:userauth_request_with_none_method_message){
        {
          :'message number' => HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
          :'user name'      => username,
          :'service name'   => "ssh-connection",
          :'method name'    => "none",
        }
      }
      let(:userauth_request_with_none_method_payload){
        HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST.encode userauth_request_with_none_method_message
      }
      let(:userauth_request_with_password_method_message){
        {
          :'message number'     => HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
          :'user name'          => username,
          :'service name'       => "ssh-connection",
          :'method name'        => "password",
          :'FALSE'              => false,
          :'plaintext password' => "password"
        }
      }
      let(:userauth_request_with_password_method_payload){
        HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST.encode userauth_request_with_password_method_message
      }
      let(:userauth_request_with_keyboard_interactive_method_message){
        {
          :'message number' => HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
          :'user name'      => username,
          :'service name'   => "ssh-connection",
          :'method name'    => "keyboard-interactive",
          :'language tag'   => "",
          :'submethods'     => "",
        }
      }
      let(:userauth_request_with_keyboard_interactive_method_payload){
        HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST.encode userauth_request_with_keyboard_interactive_method_message
      }
      let(:authentications_that_can_continue){
        ['password', 'publickey', 'keyboard-interactive']
      }
      let(:partial_success){
        true
      }

      it "sends userauth request message for password method and it is accepted after userauth request message for none method, and will return authenticated username" do
        expect( transport ).to receive(:send).with(userauth_request_with_none_method_payload).once
        expect( transport ).to receive(:send).with(userauth_request_with_password_method_payload).once
        expect( transport ).to receive(:send).with(userauth_request_with_keyboard_interactive_method_payload).once
        expect( transport ).to receive(:receive).with(no_args).and_return(userauth_failure_payload, userauth_failure_payload, userauth_success_payload).exactly(3).times

        authentication.request_authentication

        expect( authentication.closed? ).to be false
        expect( authentication.username ).to eq username
      end
    end
  end

  describe '#username' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ described_class.new(transport, mode) }
    let(:username){ "username" }

    context "when transport is not closed" do
      before :example do
        authentication.instance_variable_set('@closed', false)
        authentication.instance_variable_set('@username', username)
      end

      it "returns authenticated username" do
        expect(authentication.username).to eq username
      end
    end

    context "when transport is closed" do
      before :example do
        authentication.instance_variable_set('@closed', true)
      end

      it "raises Error::ClosedAuthentication" do
        expect { authentication.username }.to raise_error HrrRbSsh::Error::ClosedAuthentication
      end
    end
  end
end
