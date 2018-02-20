# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Message::Codable do
  let(:extended){
    Class.new do
      extend HrrRbSsh::Message::Codable

      def self.definition
        [
          ['byte',   'SSH_MSG_MOCK'],
          ['string', 'data'        ],
        ]
      end
    end
  }

  describe ".encode" do
    it "encodes #{{'SSH_MSG_MOCK' => 168, 'data' => 'testing'}.inspect} to \"A8 00 00 00 07 t e s t i n g\"" do
      expect( extended.encode( {'SSH_MSG_MOCK' => 168, 'data' => 'testing'} ) ).to eq( ["A8", "00000007", "testing"].pack("H*H*a*") )
    end
  end

  describe ".decode" do
    it "decodes \"A8 00 00 00 07 t e s t i n g\" to #{{'SSH_MSG_MOCK' => 168, 'data' => 'testing'}.inspect}" do
      expect( extended.decode( ["A8", "00000007", "testing"].pack("H*H*a*") ) ).to eq( {'SSH_MSG_MOCK' => 168, 'data' => 'testing'} )
    end
  end
end