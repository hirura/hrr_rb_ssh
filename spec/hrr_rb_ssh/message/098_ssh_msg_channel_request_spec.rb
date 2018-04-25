# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST do
  let(:id){ 'SSH_MSG_CHANNEL_REQUEST' }
  let(:value){ 98 }

  describe "::ID" do
    it "is defined" do
      expect(described_class::ID).to eq id
    end
  end

  describe "::VALUE" do
    it "is defined" do
      expect(described_class::VALUE).to eq value
    end
  end

  describe "::SignalName" do
    describe "::ABRT" do
      let(:id){ HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::SignalName::ABRT }
      let(:value){ 'ABRT' }

      it "is defined" do
        expect(id).to eq value
      end
    end

    describe "::ALRM" do
      let(:id){ HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::SignalName::ALRM }
      let(:value){ 'ALRM' }

      it "is defined" do
        expect(id).to eq value
      end
    end

    describe "::FPE" do
      let(:id){ HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::SignalName::FPE }
      let(:value){ 'FPE' }

      it "is defined" do
        expect(id).to eq value
      end
    end

    describe "::HUP" do
      let(:id){ HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::SignalName::HUP }
      let(:value){ 'HUP' }

      it "is defined" do
        expect(id).to eq value
      end
    end

    describe "::ILL" do
      let(:id){ HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::SignalName::ILL }
      let(:value){ 'ILL' }

      it "is defined" do
        expect(id).to eq value
      end
    end

    describe "::INT" do
      let(:id){ HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::SignalName::INT }
      let(:value){ 'INT' }

      it "is defined" do
        expect(id).to eq value
      end
    end

    describe "::KILL" do
    let(:id){ HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::SignalName::KILL }
    let(:value){ 'KILL' }

      it "is defined" do
        expect(id).to eq value
      end
    end

    describe "::PIPE" do
      let(:id){ HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::SignalName::PIPE }
      let(:value){ 'PIPE' }

      it "is defined" do
        expect(id).to eq value
      end
    end

    describe "::QUIT" do
      let(:id){ HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::SignalName::QUIT }
      let(:value){ 'QUIT' }

      it "is defined" do
        expect(id).to eq value
      end
    end

    describe "::SEGV" do
      let(:id){ HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::SignalName::SEGV }
      let(:value){ 'SEGV' }

      it "is defined" do
        expect(id).to eq value
      end
    end

    describe "::TERM" do
      let(:id){ HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::SignalName::TERM }
      let(:value){ 'TERM' }

      it "is defined" do
        expect(id).to eq value
      end
    end

    describe "::USR1" do
      let(:id){ HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::SignalName::USR1 }
      let(:value){ 'USR1' }

      it "is defined" do
        expect(id).to eq value
      end
    end

    describe "::USR2" do
      let(:id){ HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::SignalName::USR2 }
      let(:value){ 'USR2' }

      it "is defined" do
        expect(id).to eq value
      end
    end
  end

  context "when 'request type' is \"pty-req\"" do
    let(:message){
      {
        :'message number'                  => value,
        :'recipient channel'               => 1,
        :'request type'                    => 'pty-req',
        :'want reply'                      => true,
        :'TERM environment variable value' => 'foo',
        :'terminal width, characters'      => 80,
        :'terminal height, rows'           => 24,
        :'terminal width, pixels'          => 400,
        :'terminal height, pixels'         => 120,
        :'encoded terminal modes'          => 'bar',
      }
    }
    let(:payload){
      [
        HrrRbSsh::DataType::Byte.encode(message[:'message number']),
        HrrRbSsh::DataType::Uint32.encode(message[:'recipient channel']),
        HrrRbSsh::DataType::String.encode(message[:'request type']),
        HrrRbSsh::DataType::Boolean.encode(message[:'want reply']),
        HrrRbSsh::DataType::String.encode(message[:'TERM environment variable value']),
        HrrRbSsh::DataType::Uint32.encode(message[:'terminal width, characters']),
        HrrRbSsh::DataType::Uint32.encode(message[:'terminal height, rows']),
        HrrRbSsh::DataType::Uint32.encode(message[:'terminal width, pixels']),
        HrrRbSsh::DataType::Uint32.encode(message[:'terminal height, pixels']),
        HrrRbSsh::DataType::String.encode(message[:'encoded terminal modes']),
      ].join
    }

    describe ".encode" do
      it "returns payload encoded" do
        expect(described_class.encode(message)).to eq payload
      end
    end

    describe ".decode" do
      it "returns message decoded" do
        expect(described_class.decode(payload)).to eq message
      end
    end
  end

  context "when 'request type' is \"x11-req\"" do
    let(:message){
      {
        :'message number'              => value,
        :'recipient channel'           => 1,
        :'request type'                => 'x11-req',
        :'want reply'                  => true,
        :'single connection'           => true,
        :'x11 authentication protocol' => 'foo',
        :'x11 authentication cookie'   => 'bar',
        :'x11 screen number'           => 2,

      }
    }
    let(:payload){
      [
        HrrRbSsh::DataType::Byte.encode(message[:'message number']),
        HrrRbSsh::DataType::Uint32.encode(message[:'recipient channel']),
        HrrRbSsh::DataType::String.encode(message[:'request type']),
        HrrRbSsh::DataType::Boolean.encode(message[:'want reply']),
        HrrRbSsh::DataType::Boolean.encode(message[:'single connection']),
        HrrRbSsh::DataType::String.encode(message[:'x11 authentication protocol']),
        HrrRbSsh::DataType::String.encode(message[:'x11 authentication cookie']),
        HrrRbSsh::DataType::Uint32.encode(message[:'x11 screen number']),
      ].join
    }

    describe ".encode" do
      it "returns payload encoded" do
        expect(described_class.encode(message)).to eq payload
      end
    end

    describe ".decode" do
      it "returns message decoded" do
        expect(described_class.decode(payload)).to eq message
      end
    end
  end

  context "when 'request type' is \"env\"" do
    let(:message){
      {
        :'message number'    => value,
        :'recipient channel' => 1,
        :'request type'      => 'env',
        :'want reply'        => true,
        :'variable name'     => 'name',
        :'variable value'    => 'value',
      }
    }
    let(:payload){
      [
        HrrRbSsh::DataType::Byte.encode(message[:'message number']),
        HrrRbSsh::DataType::Uint32.encode(message[:'recipient channel']),
        HrrRbSsh::DataType::String.encode(message[:'request type']),
        HrrRbSsh::DataType::Boolean.encode(message[:'want reply']),
        HrrRbSsh::DataType::String.encode(message[:'variable name']),
        HrrRbSsh::DataType::String.encode(message[:'variable value']),
      ].join
    }

    describe ".encode" do
      it "returns payload encoded" do
        expect(described_class.encode(message)).to eq payload
      end
    end

    describe ".decode" do
      it "returns message decoded" do
        expect(described_class.decode(payload)).to eq message
      end
    end
  end

  context "when 'request type' is \"shell\"" do
    let(:message){
      {
        :'message number'    => value,
        :'recipient channel' => 1,
        :'request type'      => 'shell',
        :'want reply'        => true,
      }
    }
    let(:payload){
      [
        HrrRbSsh::DataType::Byte.encode(message[:'message number']),
        HrrRbSsh::DataType::Uint32.encode(message[:'recipient channel']),
        HrrRbSsh::DataType::String.encode(message[:'request type']),
        HrrRbSsh::DataType::Boolean.encode(message[:'want reply']),
      ].join
    }

    describe ".encode" do
      it "returns payload encoded" do
        expect(described_class.encode(message)).to eq payload
      end
    end

    describe ".decode" do
      it "returns message decoded" do
        expect(described_class.decode(payload)).to eq message
      end
    end
  end

  context "when 'request type' is \"exec\"" do
    let(:message){
      {
        :'message number'    => value,
        :'recipient channel' => 1,
        :'request type'      => 'exec',
        :'want reply'        => true,
        :'command'           => 'command',
      }
    }
    let(:payload){
      [
        HrrRbSsh::DataType::Byte.encode(message[:'message number']),
        HrrRbSsh::DataType::Uint32.encode(message[:'recipient channel']),
        HrrRbSsh::DataType::String.encode(message[:'request type']),
        HrrRbSsh::DataType::Boolean.encode(message[:'want reply']),
        HrrRbSsh::DataType::String.encode(message[:'command']),
      ].join
    }

    describe ".encode" do
      it "returns payload encoded" do
        expect(described_class.encode(message)).to eq payload
      end
    end

    describe ".decode" do
      it "returns message decoded" do
        expect(described_class.decode(payload)).to eq message
      end
    end
  end

  context "when 'request type' is \"subsystem\"" do
    let(:message){
      {
        :'message number'    => value,
        :'recipient channel' => 1,
        :'request type'      => 'subsystem',
        :'want reply'        => true,
        :'subsystem name'    => 'subsystem',
      }
    }
    let(:payload){
      [
        HrrRbSsh::DataType::Byte.encode(message[:'message number']),
        HrrRbSsh::DataType::Uint32.encode(message[:'recipient channel']),
        HrrRbSsh::DataType::String.encode(message[:'request type']),
        HrrRbSsh::DataType::Boolean.encode(message[:'want reply']),
        HrrRbSsh::DataType::String.encode(message[:'subsystem name']),
      ].join
    }

    describe ".encode" do
      it "returns payload encoded" do
        expect(described_class.encode(message)).to eq payload
      end
    end

    describe ".decode" do
      it "returns message decoded" do
        expect(described_class.decode(payload)).to eq message
      end
    end
  end

  context "when 'request type' is \"window-change\"" do
    let(:message){
      {
        :'message number'          => value,
        :'recipient channel'       => 1,
        :'request type'            => 'window-change',
        :'want reply'              => true,
        :'terminal width, columns' => 80,
        :'terminal height, rows'   => 24,
        :'terminal width, pixels'  => 400,
        :'terminal height, pixels' => 120,
      }
    }
    let(:payload){
      [
        HrrRbSsh::DataType::Byte.encode(message[:'message number']),
        HrrRbSsh::DataType::Uint32.encode(message[:'recipient channel']),
        HrrRbSsh::DataType::String.encode(message[:'request type']),
        HrrRbSsh::DataType::Boolean.encode(message[:'want reply']),
        HrrRbSsh::DataType::Uint32.encode(message[:'terminal width, columns']),
        HrrRbSsh::DataType::Uint32.encode(message[:'terminal height, rows']),
        HrrRbSsh::DataType::Uint32.encode(message[:'terminal width, pixels']),
        HrrRbSsh::DataType::Uint32.encode(message[:'terminal height, pixels']),
      ].join
    }

    describe ".encode" do
      it "returns payload encoded" do
        expect(described_class.encode(message)).to eq payload
      end
    end

    describe ".decode" do
      it "returns message decoded" do
        expect(described_class.decode(payload)).to eq message
      end
    end
  end

  context "when 'request type' is \"xon-xoff\"" do
    let(:message){
      {
        :'message number'    => value,
        :'recipient channel' => 1,
        :'request type'      => 'xon-xoff',
        :'want reply'        => true,
        :'client can do'     => true,
      }
    }
    let(:payload){
      [
        HrrRbSsh::DataType::Byte.encode(message[:'message number']),
        HrrRbSsh::DataType::Uint32.encode(message[:'recipient channel']),
        HrrRbSsh::DataType::String.encode(message[:'request type']),
        HrrRbSsh::DataType::Boolean.encode(message[:'want reply']),
        HrrRbSsh::DataType::Boolean.encode(message[:'client can do']),
      ].join
    }

    describe ".encode" do
      it "returns payload encoded" do
        expect(described_class.encode(message)).to eq payload
      end
    end

    describe ".decode" do
      it "returns message decoded" do
        expect(described_class.decode(payload)).to eq message
      end
    end
  end

  context "when 'request type' is \"signal\"" do
    let(:message){
      {
        :'message number'    => value,
        :'recipient channel' => 1,
        :'request type'      => 'signal',
        :'want reply'        => true,
        :'signal name'       => 'signal',
      }
    }
    let(:payload){
      [
        HrrRbSsh::DataType::Byte.encode(message[:'message number']),
        HrrRbSsh::DataType::Uint32.encode(message[:'recipient channel']),
        HrrRbSsh::DataType::String.encode(message[:'request type']),
        HrrRbSsh::DataType::Boolean.encode(message[:'want reply']),
        HrrRbSsh::DataType::String.encode(message[:'signal name']),
      ].join
    }

    describe ".encode" do
      it "returns payload encoded" do
        expect(described_class.encode(message)).to eq payload
      end
    end

    describe ".decode" do
      it "returns message decoded" do
        expect(described_class.decode(payload)).to eq message
      end
    end
  end

  context "when 'request type' is \"exit-status\"" do
    let(:message){
      {
        :'message number'    => value,
        :'recipient channel' => 1,
        :'request type'      => 'exit-status',
        :'want reply'        => true,
        :'exit status'       => 2,
      }
    }
    let(:payload){
      [
        HrrRbSsh::DataType::Byte.encode(message[:'message number']),
        HrrRbSsh::DataType::Uint32.encode(message[:'recipient channel']),
        HrrRbSsh::DataType::String.encode(message[:'request type']),
        HrrRbSsh::DataType::Boolean.encode(message[:'want reply']),
        HrrRbSsh::DataType::Uint32.encode(message[:'exit status']),
      ].join
    }

    describe ".encode" do
      it "returns payload encoded" do
        expect(described_class.encode(message)).to eq payload
      end
    end

    describe ".decode" do
      it "returns message decoded" do
        expect(described_class.decode(payload)).to eq message
      end
    end
  end

  context "when 'request type' is \"exit-signal\"" do
    let(:message){
      {
        :'message number'    => value,
        :'recipient channel' => 1,
        :'request type'      => 'exit-signal',
        :'want reply'        => true,
        :'signal name'       => 'sig',
        :'core dumped'       => true,
        :'error message'     => 'error',
        :'language tag'      => 'tag',
      }
    }
    let(:payload){
      [
        HrrRbSsh::DataType::Byte.encode(message[:'message number']),
        HrrRbSsh::DataType::Uint32.encode(message[:'recipient channel']),
        HrrRbSsh::DataType::String.encode(message[:'request type']),
        HrrRbSsh::DataType::Boolean.encode(message[:'want reply']),
        HrrRbSsh::DataType::String.encode(message[:'signal name']),
        HrrRbSsh::DataType::Boolean.encode(message[:'core dumped']),
        HrrRbSsh::DataType::String.encode(message[:'error message']),
        HrrRbSsh::DataType::String.encode(message[:'language tag']),
      ].join
    }

    describe ".encode" do
      it "returns payload encoded" do
        expect(described_class.encode(message)).to eq payload
      end
    end

    describe ".decode" do
      it "returns message decoded" do
        expect(described_class.decode(payload)).to eq message
      end
    end
  end
end
