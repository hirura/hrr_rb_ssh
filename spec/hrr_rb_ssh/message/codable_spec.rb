# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Message::Codable do
  let(:mixed_in){
    Module.new do
      class << self
        include HrrRbSsh::Message::Codable

        def definition
          [
            ['byte',   'SSH_MSG_MOCK'],
            ['string', 'data'        ],
          ]
        end
      end
    end
  }

  describe ".encode" do
    it "encodes #{{'SSH_MSG_MOCK' => 168, 'data' => 'testing'}.inspect} to \"A8 00 00 00 07 t e s t i n g\"" do
      expect( mixed_in.encode( {'SSH_MSG_MOCK' => 168, 'data' => 'testing'} ) ).to eq( ["A8", "00000007", "testing"].pack("H*H*a*") )
    end
  end

  describe ".decode" do
    it "decodes \"A8 00 00 00 07 t e s t i n g\" to #{{'SSH_MSG_MOCK' => 168, 'data' => 'testing'}.inspect}" do
      expect( mixed_in.decode( ["A8", "00000007", "testing"].pack("H*H*a*") ) ).to eq( {'SSH_MSG_MOCK' => 168, 'data' => 'testing'} )
    end
  end
end
