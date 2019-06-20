# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Authentication::Method::KeyboardInteractive do
  let(:name){ 'keyboard-interactive' }
  let(:transport){ double('transport') }

  it "can be looked up in HrrRbSsh::Authentication::Method dictionary" do
    expect( HrrRbSsh::Authentication::Method[name] ).to eq described_class
  end                              

  it "is registered in HrrRbSsh::Authentication::Method.list_supported" do
    expect( HrrRbSsh::Authentication::Method.list_supported ).to include name
  end         

  it "appears in HrrRbSsh::Authentication::Method.list_preferred" do
    expect( HrrRbSsh::Authentication::Method.list_preferred ).to include name
  end           

  describe ".new" do
    it "takes three arguments: transport, options, and variables" do
      expect { described_class.new(transport, {}, {}) }.not_to raise_error
    end     
  end

  describe "#authenticate" do
    let(:userauth_request_message){
      {
        :'user name'  => "username",
        :'submethods' => "submethods",
      }
    }

    context "when options does not have 'authentication_keyboard_interactive_authenticator'" do
      let(:options){ {} }
      let(:variables){ {} }
      let(:keyboard_interactive_method){ described_class.new transport, options, variables }

      it "returns false" do
        expect( keyboard_interactive_method.authenticate userauth_request_message ).to be false
      end
    end

    context "when options has 'authentication_keyboard_interactive_authenticator'" do
      let(:variables){ {} }
      let(:keyboard_interactive_authenticator){
        HrrRbSsh::Authentication::Authenticator.new { |context|
          user_name        = 'username'
          req_name         = 'keyboard interactive authentication'
          req_instruction  = 'instruction'
          req_language_tag = ''
          req_prompts = [
            ['Password1: ', false],
            ['Password2: ', true],
          ]
          info_response = context.info_request req_name, req_instruction, req_language_tag, req_prompts
          context.username == user_name && info_response.responses == ['password1', 'password2']
        }
      }
      let(:keyboard_interactive_method){ described_class.new transport, options, variables }
      let(:userauth_info_request_message){
        {
          :'message number' => HrrRbSsh::Message::SSH_MSG_USERAUTH_INFO_REQUEST::VALUE,
          :'name'           => "keyboard interactive authentication",
          :'instruction'    => "instruction",
          :'language tag'   => "",
          :'num-prompts'    => 2,
          :'prompt[1]'      => "Password1: ",
          :'echo[1]'        => false,
          :'prompt[2]'      => "Password2: ",
          :'echo[2]'        => true
        }
      }
      let(:userauth_info_request_payload){
        HrrRbSsh::Message::SSH_MSG_USERAUTH_INFO_REQUEST.encode userauth_info_request_message
      }
      let(:userauth_info_response_message){
        {
          :'message number' => HrrRbSsh::Message::SSH_MSG_USERAUTH_INFO_RESPONSE::VALUE,
          :'num-responses'  => 2,
          :'response[1]'    => password1,
          :'response[2]'    => password2,
        }
      }
      let(:userauth_info_response_payload){
        HrrRbSsh::Message::SSH_MSG_USERAUTH_INFO_RESPONSE.encode userauth_info_response_message
      }

      context "when authenticator returns true" do
        let(:options){
          {
            'authentication_keyboard_interactive_authenticator' => HrrRbSsh::Authentication::Authenticator.new { true }
          }
        }

        it "returns true" do
          expect( keyboard_interactive_method.authenticate userauth_request_message ).to be true
        end
      end

      context "when authenticator  gets expected info response" do
        let(:password1){ 'password1' }
        let(:password2){ 'password2' }
        let(:options){
          {
            'authentication_keyboard_interactive_authenticator' => keyboard_interactive_authenticator
          }
        }

        it "returns true" do
          expect(transport).to receive(:send).with(userauth_info_request_payload).and_return(nil)
          expect(transport).to receive(:receive).with(no_args).and_return(userauth_info_response_payload)

          expect( keyboard_interactive_method.authenticate userauth_request_message ).to be true
        end
      end

      context "when authenticator gets unexpected info response" do
        let(:password1){ 'password1' }
        let(:password2){ 'invalid password' }
        let(:options){
          {
            'authentication_keyboard_interactive_authenticator' => keyboard_interactive_authenticator
          }
        }

        it "returns false" do
          expect(transport).to receive(:send).with(userauth_info_request_payload).and_return(nil)
          expect(transport).to receive(:receive).with(no_args).and_return(userauth_info_response_payload)

          expect( keyboard_interactive_method.authenticate userauth_request_message ).to be false
        end
      end

      context "when authenticator gets invalid message" do
        let(:invalid_message_number){ 193 }
        let(:userauth_info_response_payload){ HrrRbSsh::DataType::Byte.encode invalid_message_number }
        let(:password1){ 'password1' }
        let(:password2){ 'password2' }
        let(:options){
          {
            'authentication_keyboard_interactive_authenticator' => keyboard_interactive_authenticator
          }
        }

        it "raises error" do
          expect(transport).to receive(:send).with(userauth_info_request_payload).and_return(nil)
          expect(transport).to receive(:receive).with(no_args).and_return(userauth_info_response_payload)

          expect { keyboard_interactive_method.authenticate userauth_request_message }.to raise_error RuntimeError
        end
      end
    end
  end
end
