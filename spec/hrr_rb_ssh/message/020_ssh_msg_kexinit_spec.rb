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

  let(:kex_algorithms){ HrrRbSsh::Transport::KexAlgorithm.name_list }
  let(:server_host_key_algorithms){ HrrRbSsh::Transport::ServerHostKeyAlgorithm.name_list }
  let(:encryption_algorithms){ HrrRbSsh::Transport::EncryptionAlgorithm.name_list }
  let(:encryption_algorithms){ HrrRbSsh::Transport::EncryptionAlgorithm.name_list }
  let(:mac_algorithms){ HrrRbSsh::Transport::MacAlgorithm.name_list }
  let(:mac_algorithms){ HrrRbSsh::Transport::MacAlgorithm.name_list }
  let(:compression_algorithms){ HrrRbSsh::Transport::CompressionAlgorithm.name_list }
  let(:compression_algorithms){ HrrRbSsh::Transport::CompressionAlgorithm.name_list }
  let(:message){
    {
      id                                        => value,
      'cookie (random byte)'                    => lambda { rand(0x01_00) },
      'kex_algorithms'                          => kex_algorithms,
      'server_host_key_algorithms'              => server_host_key_algorithms,
      'encryption_algorithms_client_to_server'  => encryption_algorithms,
      'encryption_algorithms_server_to_client'  => encryption_algorithms,
      'mac_algorithms_client_to_server'         => mac_algorithms,
      'mac_algorithms_server_to_client'         => mac_algorithms,
      'compression_algorithms_client_to_server' => compression_algorithms,
      'compression_algorithms_server_to_client' => compression_algorithms,
      'languages_client_to_server'              => [],
      'languages_server_to_client'              => [],
      'first_kex_packet_follows'                => false,
      '0 (reserved for future extension)'       => 0,
    }
  }
  let(:payload){
    [
      HrrRbSsh::Transport::DataType::Byte.encode(message[id]),
      HrrRbSsh::Transport::DataType::Byte.encode(message['cookie (random byte)'].call),
      HrrRbSsh::Transport::DataType::Byte.encode(message['cookie (random byte)'].call),
      HrrRbSsh::Transport::DataType::Byte.encode(message['cookie (random byte)'].call),
      HrrRbSsh::Transport::DataType::Byte.encode(message['cookie (random byte)'].call),
      HrrRbSsh::Transport::DataType::Byte.encode(message['cookie (random byte)'].call),
      HrrRbSsh::Transport::DataType::Byte.encode(message['cookie (random byte)'].call),
      HrrRbSsh::Transport::DataType::Byte.encode(message['cookie (random byte)'].call),
      HrrRbSsh::Transport::DataType::Byte.encode(message['cookie (random byte)'].call),
      HrrRbSsh::Transport::DataType::Byte.encode(message['cookie (random byte)'].call),
      HrrRbSsh::Transport::DataType::Byte.encode(message['cookie (random byte)'].call),
      HrrRbSsh::Transport::DataType::Byte.encode(message['cookie (random byte)'].call),
      HrrRbSsh::Transport::DataType::Byte.encode(message['cookie (random byte)'].call),
      HrrRbSsh::Transport::DataType::Byte.encode(message['cookie (random byte)'].call),
      HrrRbSsh::Transport::DataType::Byte.encode(message['cookie (random byte)'].call),
      HrrRbSsh::Transport::DataType::Byte.encode(message['cookie (random byte)'].call),
      HrrRbSsh::Transport::DataType::Byte.encode(message['cookie (random byte)'].call),
      HrrRbSsh::Transport::DataType::NameList.encode(message['kex_algorithms']),
      HrrRbSsh::Transport::DataType::NameList.encode(message['server_host_key_algorithms']),
      HrrRbSsh::Transport::DataType::NameList.encode(message['encryption_algorithms_client_to_server']),
      HrrRbSsh::Transport::DataType::NameList.encode(message['encryption_algorithms_server_to_client']),
      HrrRbSsh::Transport::DataType::NameList.encode(message['mac_algorithms_client_to_server']),
      HrrRbSsh::Transport::DataType::NameList.encode(message['mac_algorithms_server_to_client']),
      HrrRbSsh::Transport::DataType::NameList.encode(message['compression_algorithms_client_to_server']),
      HrrRbSsh::Transport::DataType::NameList.encode(message['compression_algorithms_server_to_client']),
      HrrRbSsh::Transport::DataType::NameList.encode(message['languages_client_to_server']),
      HrrRbSsh::Transport::DataType::NameList.encode(message['languages_server_to_client']),
      HrrRbSsh::Transport::DataType::Boolean.encode(message['first_kex_packet_follows']),
      HrrRbSsh::Transport::DataType::Uint32.encode(message['0 (reserved for future extension)']),
    ].join
  }

  describe ".encode" do
    it "returns payload encoded" do
      expect(described_class.encode(message)[0,1]).to eq payload[0,1]
      expect(described_class.encode(message)[17,(payload.length-1)]).to eq payload[17,(payload.length-1)]
    end
  end

  describe ".decode" do
    it "returns message decoded" do
      expect(described_class.decode(payload)[id]).to eq message[id]
      expect(described_class.decode(payload)['kex_algorithms']).to eq message['kex_algorithms']
      expect(described_class.decode(payload)['server_host_key_algorithms']).to eq message['server_host_key_algorithms']
      expect(described_class.decode(payload)['encryption_algorithms_client_to_server']).to eq message['encryption_algorithms_client_to_server']
      expect(described_class.decode(payload)['encryption_algorithms_server_to_client']).to eq message['encryption_algorithms_server_to_client']
      expect(described_class.decode(payload)['mac_algorithms_client_to_server']).to eq message['mac_algorithms_client_to_server']
      expect(described_class.decode(payload)['mac_algorithms_server_to_client']).to eq message['mac_algorithms_server_to_client']
      expect(described_class.decode(payload)['compression_algorithms_client_to_server']).to eq message['compression_algorithms_client_to_server']
      expect(described_class.decode(payload)['compression_algorithms_server_to_client']).to eq message['compression_algorithms_server_to_client']
      expect(described_class.decode(payload)['languages_client_to_server']).to eq message['languages_client_to_server']
      expect(described_class.decode(payload)['languages_server_to_client']).to eq message['languages_server_to_client']
      expect(described_class.decode(payload)['first_kex_packet_follows']).to eq message['first_kex_packet_follows']
      expect(described_class.decode(payload)['0 (reserved for future extension)']).to eq message['0 (reserved for future extension)']
    end
  end
end
