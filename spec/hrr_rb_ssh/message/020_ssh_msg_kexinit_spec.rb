# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Message::SSH_MSG_KEXINIT do
  let(:id){ 'SSH_MSG_KEXINIT' }
  let(:value){ 20 }

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

  let(:kex_algorithms){ HrrRbSsh::Transport::KexAlgorithm.list_preferred }
  let(:server_host_key_algorithms){ HrrRbSsh::Transport::ServerHostKeyAlgorithm.list_preferred }
  let(:encryption_algorithms){ HrrRbSsh::Transport::EncryptionAlgorithm.list_preferred }
  let(:encryption_algorithms){ HrrRbSsh::Transport::EncryptionAlgorithm.list_preferred }
  let(:mac_algorithms){ HrrRbSsh::Transport::MacAlgorithm.list_preferred }
  let(:mac_algorithms){ HrrRbSsh::Transport::MacAlgorithm.list_preferred }
  let(:compression_algorithms){ HrrRbSsh::Transport::CompressionAlgorithm.list_preferred }
  let(:compression_algorithms){ HrrRbSsh::Transport::CompressionAlgorithm.list_preferred }
  let(:message){
    {
      :'message number'                          => value,
      :'cookie (random byte)'                    => lambda { rand(0x01_00) },
      :'kex_algorithms'                          => kex_algorithms,
      :'server_host_key_algorithms'              => server_host_key_algorithms,
      :'encryption_algorithms_client_to_server'  => encryption_algorithms,
      :'encryption_algorithms_server_to_client'  => encryption_algorithms,
      :'mac_algorithms_client_to_server'         => mac_algorithms,
      :'mac_algorithms_server_to_client'         => mac_algorithms,
      :'compression_algorithms_client_to_server' => compression_algorithms,
      :'compression_algorithms_server_to_client' => compression_algorithms,
      :'languages_client_to_server'              => [],
      :'languages_server_to_client'              => [],
      :'first_kex_packet_follows'                => false,
      :'0 (reserved for future extension)'       => 0,
    }
  }
  let(:payload){
    [
      HrrRbSsh::DataTypes::Byte.encode(message[:'message number']),
      HrrRbSsh::DataTypes::Byte.encode(message[:'cookie (random byte)'].call),
      HrrRbSsh::DataTypes::Byte.encode(message[:'cookie (random byte)'].call),
      HrrRbSsh::DataTypes::Byte.encode(message[:'cookie (random byte)'].call),
      HrrRbSsh::DataTypes::Byte.encode(message[:'cookie (random byte)'].call),
      HrrRbSsh::DataTypes::Byte.encode(message[:'cookie (random byte)'].call),
      HrrRbSsh::DataTypes::Byte.encode(message[:'cookie (random byte)'].call),
      HrrRbSsh::DataTypes::Byte.encode(message[:'cookie (random byte)'].call),
      HrrRbSsh::DataTypes::Byte.encode(message[:'cookie (random byte)'].call),
      HrrRbSsh::DataTypes::Byte.encode(message[:'cookie (random byte)'].call),
      HrrRbSsh::DataTypes::Byte.encode(message[:'cookie (random byte)'].call),
      HrrRbSsh::DataTypes::Byte.encode(message[:'cookie (random byte)'].call),
      HrrRbSsh::DataTypes::Byte.encode(message[:'cookie (random byte)'].call),
      HrrRbSsh::DataTypes::Byte.encode(message[:'cookie (random byte)'].call),
      HrrRbSsh::DataTypes::Byte.encode(message[:'cookie (random byte)'].call),
      HrrRbSsh::DataTypes::Byte.encode(message[:'cookie (random byte)'].call),
      HrrRbSsh::DataTypes::Byte.encode(message[:'cookie (random byte)'].call),
      HrrRbSsh::DataTypes::NameList.encode(message[:'kex_algorithms']),
      HrrRbSsh::DataTypes::NameList.encode(message[:'server_host_key_algorithms']),
      HrrRbSsh::DataTypes::NameList.encode(message[:'encryption_algorithms_client_to_server']),
      HrrRbSsh::DataTypes::NameList.encode(message[:'encryption_algorithms_server_to_client']),
      HrrRbSsh::DataTypes::NameList.encode(message[:'mac_algorithms_client_to_server']),
      HrrRbSsh::DataTypes::NameList.encode(message[:'mac_algorithms_server_to_client']),
      HrrRbSsh::DataTypes::NameList.encode(message[:'compression_algorithms_client_to_server']),
      HrrRbSsh::DataTypes::NameList.encode(message[:'compression_algorithms_server_to_client']),
      HrrRbSsh::DataTypes::NameList.encode(message[:'languages_client_to_server']),
      HrrRbSsh::DataTypes::NameList.encode(message[:'languages_server_to_client']),
      HrrRbSsh::DataTypes::Boolean.encode(message[:'first_kex_packet_follows']),
      HrrRbSsh::DataTypes::Uint32.encode(message[:'0 (reserved for future extension)']),
    ].join
  }

  describe "#encode" do
    it "returns payload encoded" do
      expect(described_class.new.encode(message)[0,1]).to eq payload[0,1]
      expect(described_class.new.encode(message)[17,(payload.length-1)]).to eq payload[17,(payload.length-1)]
    end
  end

  describe "#decode" do
    it "returns message decoded" do
      expect(described_class.new.decode(payload)[:'message number']).to eq message[:'message number']
      expect(described_class.new.decode(payload)[:'kex_algorithms']).to eq message[:'kex_algorithms']
      expect(described_class.new.decode(payload)[:'server_host_key_algorithms']).to eq message[:'server_host_key_algorithms']
      expect(described_class.new.decode(payload)[:'encryption_algorithms_client_to_server']).to eq message[:'encryption_algorithms_client_to_server']
      expect(described_class.new.decode(payload)[:'encryption_algorithms_server_to_client']).to eq message[:'encryption_algorithms_server_to_client']
      expect(described_class.new.decode(payload)[:'mac_algorithms_client_to_server']).to eq message[:'mac_algorithms_client_to_server']
      expect(described_class.new.decode(payload)[:'mac_algorithms_server_to_client']).to eq message[:'mac_algorithms_server_to_client']
      expect(described_class.new.decode(payload)[:'compression_algorithms_client_to_server']).to eq message[:'compression_algorithms_client_to_server']
      expect(described_class.new.decode(payload)[:'compression_algorithms_server_to_client']).to eq message[:'compression_algorithms_server_to_client']
      expect(described_class.new.decode(payload)[:'languages_client_to_server']).to eq message[:'languages_client_to_server']
      expect(described_class.new.decode(payload)[:'languages_server_to_client']).to eq message[:'languages_server_to_client']
      expect(described_class.new.decode(payload)[:'first_kex_packet_follows']).to eq message[:'first_kex_packet_follows']
      expect(described_class.new.decode(payload)[:'0 (reserved for future extension)']).to eq message[:'0 (reserved for future extension)']
    end
  end
end
