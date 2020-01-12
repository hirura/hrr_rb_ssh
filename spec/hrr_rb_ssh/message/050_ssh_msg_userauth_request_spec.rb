# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST do
  let(:id){ 'SSH_MSG_USERAUTH_REQUEST' }
  let(:value){ 50 }

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

  context "when 'method name' is \"none\"" do
    let(:message){
      {
        :'message number' => value,
        :'user name'      => 'rspec',
        :'service name'   => 'ssh-connection',
        :'method name'    => 'none',
      }
    }
    let(:payload){
      [
        HrrRbSsh::DataType::Byte.encode(message[:'message number']),
        HrrRbSsh::DataType::String.encode(message[:'user name']),
        HrrRbSsh::DataType::String.encode(message[:'service name']),
        HrrRbSsh::DataType::String.encode(message[:'method name']),
      ].join
    }

    describe "#encode" do
      it "returns payload encoded" do
        expect(described_class.new.encode(message)).to eq payload
      end
    end

    describe "#decode" do
      it "returns message decoded" do
        expect(described_class.new.decode(payload)).to eq message
      end
    end
  end

  context "when 'method name' is \"password\"" do
    let(:message){
      {
        :'message number'     => value,
        :'user name'          => 'rspec',
        :'service name'       => 'ssh-connection',
        :'method name'        => 'password',
        :'FALSE'              => false,
        :'plaintext password' => 'password',
      }
    }
    let(:payload){
      [
        HrrRbSsh::DataType::Byte.encode(message[:'message number']),
        HrrRbSsh::DataType::String.encode(message[:'user name']),
        HrrRbSsh::DataType::String.encode(message[:'service name']),
        HrrRbSsh::DataType::String.encode(message[:'method name']),
        HrrRbSsh::DataType::Boolean.encode(message[:'FALSE']),
        HrrRbSsh::DataType::String.encode(message[:'plaintext password']),
      ].join
    }

    describe "#encode" do
      it "returns payload encoded" do
        expect(described_class.new.encode(message)).to eq payload
      end
    end

    describe "#decode" do
      it "returns message decoded" do
        expect(described_class.new.decode(payload)).to eq message
      end
    end
  end

  context "when 'method name' is \"publickey\"" do
    context "without signature" do
      let(:message){
        {
          :'message number'            => value,
          :'user name'                 => 'rspec',
          :'service name'              => 'ssh-connection',
          :'method name'               => 'publickey',
          :'with signature'            => false,
          :'public key algorithm name' => 'ssh-rsa',
          :'public key blob'           => 'dummy',
        }
      }
      let(:payload){
        [
          HrrRbSsh::DataType::Byte.encode(message[:'message number']),
          HrrRbSsh::DataType::String.encode(message[:'user name']),
          HrrRbSsh::DataType::String.encode(message[:'service name']),
          HrrRbSsh::DataType::String.encode(message[:'method name']),
          HrrRbSsh::DataType::Boolean.encode(message[:'with signature']),
          HrrRbSsh::DataType::String.encode(message[:'public key algorithm name']),
          HrrRbSsh::DataType::String.encode(message[:'public key blob']),
        ].join
      }

      describe "#encode" do
        it "returns payload encoded" do
          expect(described_class.new.encode(message)).to eq payload
        end
      end

      describe "#decode" do
        it "returns message decoded" do
          expect(described_class.new.decode(payload)).to eq message
        end
      end
    end
  end

  context "with signature" do
    let(:message){
      {
        :'message number'            => value,
        :'user name'                 => 'rspec',
        :'service name'              => 'ssh-connection',
        :'method name'               => 'publickey',
        :'with signature'            => true,
        :'public key algorithm name' => 'ssh-rsa',
        :'public key blob'           => 'dummy',
        :'signature'                 => 'dummy',
      }
    }
    let(:payload){
      [
        HrrRbSsh::DataType::Byte.encode(message[:'message number']),
        HrrRbSsh::DataType::String.encode(message[:'user name']),
        HrrRbSsh::DataType::String.encode(message[:'service name']),
        HrrRbSsh::DataType::String.encode(message[:'method name']),
        HrrRbSsh::DataType::Boolean.encode(message[:'with signature']),
        HrrRbSsh::DataType::String.encode(message[:'public key algorithm name']),
        HrrRbSsh::DataType::String.encode(message[:'public key blob']),
        HrrRbSsh::DataType::String.encode(message[:'signature']),
      ].join
    }

    describe "#encode" do
      it "returns payload encoded" do
        expect(described_class.new.encode(message)).to eq payload
      end
    end

    describe "#decode" do
      it "returns message decoded" do
        expect(described_class.new.decode(payload)).to eq message
      end
    end
  end

  context "when 'method name' is \"keyboard-interactive\"" do
    let(:message){
      {
        :'message number' => value,
        :'user name'      => 'rspec',
        :'service name'   => 'ssh-connection',
        :'method name'    => 'keyboard-interactive',
        :'language tag'   => '',
        :'submethods'     => '',
      }
    }
    let(:payload){
      [
        HrrRbSsh::DataType::Byte.encode(message[:'message number']),
        HrrRbSsh::DataType::String.encode(message[:'user name']),
        HrrRbSsh::DataType::String.encode(message[:'service name']),
        HrrRbSsh::DataType::String.encode(message[:'method name']),
        HrrRbSsh::DataType::String.encode(message[:'language tag']),
        HrrRbSsh::DataType::String.encode(message[:'submethods']),
      ].join
    }

    describe "#encode" do
      it "returns payload encoded" do
        expect(described_class.new.encode(message)).to eq payload
      end
    end

    describe "#decode" do
      it "returns message decoded" do
        expect(described_class.new.decode(payload)).to eq message
      end
    end
  end
end
