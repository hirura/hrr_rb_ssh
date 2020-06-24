RSpec.describe HrrRbSsh::Messages::SSH_MSG_USERAUTH_REQUEST do
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
        HrrRbSsh::DataTypes::Byte.encode(message[:'message number']),
        HrrRbSsh::DataTypes::String.encode(message[:'user name']),
        HrrRbSsh::DataTypes::String.encode(message[:'service name']),
        HrrRbSsh::DataTypes::String.encode(message[:'method name']),
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
        HrrRbSsh::DataTypes::Byte.encode(message[:'message number']),
        HrrRbSsh::DataTypes::String.encode(message[:'user name']),
        HrrRbSsh::DataTypes::String.encode(message[:'service name']),
        HrrRbSsh::DataTypes::String.encode(message[:'method name']),
        HrrRbSsh::DataTypes::Boolean.encode(message[:'FALSE']),
        HrrRbSsh::DataTypes::String.encode(message[:'plaintext password']),
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
          HrrRbSsh::DataTypes::Byte.encode(message[:'message number']),
          HrrRbSsh::DataTypes::String.encode(message[:'user name']),
          HrrRbSsh::DataTypes::String.encode(message[:'service name']),
          HrrRbSsh::DataTypes::String.encode(message[:'method name']),
          HrrRbSsh::DataTypes::Boolean.encode(message[:'with signature']),
          HrrRbSsh::DataTypes::String.encode(message[:'public key algorithm name']),
          HrrRbSsh::DataTypes::String.encode(message[:'public key blob']),
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
        HrrRbSsh::DataTypes::Byte.encode(message[:'message number']),
        HrrRbSsh::DataTypes::String.encode(message[:'user name']),
        HrrRbSsh::DataTypes::String.encode(message[:'service name']),
        HrrRbSsh::DataTypes::String.encode(message[:'method name']),
        HrrRbSsh::DataTypes::Boolean.encode(message[:'with signature']),
        HrrRbSsh::DataTypes::String.encode(message[:'public key algorithm name']),
        HrrRbSsh::DataTypes::String.encode(message[:'public key blob']),
        HrrRbSsh::DataTypes::String.encode(message[:'signature']),
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
        HrrRbSsh::DataTypes::Byte.encode(message[:'message number']),
        HrrRbSsh::DataTypes::String.encode(message[:'user name']),
        HrrRbSsh::DataTypes::String.encode(message[:'service name']),
        HrrRbSsh::DataTypes::String.encode(message[:'method name']),
        HrrRbSsh::DataTypes::String.encode(message[:'language tag']),
        HrrRbSsh::DataTypes::String.encode(message[:'submethods']),
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
