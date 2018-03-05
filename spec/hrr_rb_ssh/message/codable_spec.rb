# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Message::Codable do
  context "when module does not have CONDITIONAL_DEFINITION" do
    before :context do
      module SSH_MSG_MOCK_WITH_NO_CONDITIONAL_DEFINITION
        class << self
          include HrrRbSsh::Message::Codable
        end

        DEFINITION = [
          ['byte',   'SSH_MSG_MOCK'],
          ['string', 'data'        ],
        ]
      end
    end

    let(:mixed_in){
      SSH_MSG_MOCK_WITH_NO_CONDITIONAL_DEFINITION
    }

    describe ".encode" do
      context "when arg does not contain an instance of Proc" do
        it "encodes #{{'SSH_MSG_MOCK' => 168, 'data' => 'testing'}.inspect} to \"A8 00 00 00 07 t e s t i n g\"" do
          expect( mixed_in.encode( {'SSH_MSG_MOCK' => 168, 'data' => 'testing'} ) ).to eq( ["A8", "00000007", "testing"].pack("H*H*a*") )
        end
      end

      context "when arg contains an instance of Proc" do
        it "encodes #{{'SSH_MSG_MOCK' => 168, 'data' => lambda { 'testing' }}.inspect} to \"A8 00 00 00 07 t e s t i n g\"" do
          expect( mixed_in.encode( {'SSH_MSG_MOCK' => 168, 'data' => lambda { 'testing' }} ) ).to eq( ["A8", "00000007", "testing"].pack("H*H*a*") )
        end
      end
    end

    describe ".decode" do
      it "decodes \"A8 00 00 00 07 t e s t i n g\" to #{{'SSH_MSG_MOCK' => 168, 'data' => 'testing'}.inspect}" do
        expect( mixed_in.decode( ["A8", "00000007", "testing"].pack("H*H*a*") ) ).to eq( {'SSH_MSG_MOCK' => 168, 'data' => 'testing'} )
      end
    end
  end

  context "when module has CONDITIONAL_DEFINITION" do
    before :context do
      module SSH_MSG_MOCK_WITH_CONDITIONAL_DEFINITION
        class << self
          include HrrRbSsh::Message::Codable
        end

        DEFINITION = [
          ['byte',   'SSH_MSG_MOCK'],
          ['string', 'data'        ],
        ]

        TESTING_DEFINITION = [
          ['string', 'testing data'],
        ]

        CONDITIONAL_DEFINITION = {
          'data' => {
            'testing' => TESTING_DEFINITION,
          },
        }
      end
    end

    let(:mixed_in){
      SSH_MSG_MOCK_WITH_CONDITIONAL_DEFINITION
    }

    describe ".encode" do
      context "when arg does not contain an instance of Proc" do
        it "encodes #{{'SSH_MSG_MOCK' => 168, 'data' => 'testing', 'testing data' => 'conditional'}.inspect} to \"A8 00 00 00 07 t e s t i n g 00 00 00 0B c o n d i t i o n a l\"" do
          expect( mixed_in.encode( {'SSH_MSG_MOCK' => 168, 'data' => 'testing', 'testing data' => 'conditional'} ) ).to eq( ["A8", "00000007", "testing", "0000000B", "conditional"].pack("H*H*a*H*a*") )
        end
      end

      context "when arg contains an instance of Proc" do
        it "encodes #{{'SSH_MSG_MOCK' => 168, 'data' => lambda { 'testing' }, 'testing data' => lambda { 'conditional' }}.inspect} to \"A8 00 00 00 07 t e s t i n g 00 00 00 0B c o n d i t i o n a l\"" do
          expect( mixed_in.encode( {'SSH_MSG_MOCK' => 168, 'data' => lambda { 'testing' }, 'testing data' => lambda { 'conditional' }} ) ).to eq( ["A8", "00000007", "testing", "0000000B", "conditional"].pack("H*H*a*H*a*") )
        end
      end
    end

    describe ".decode" do
      it "decodes \"A8 00 00 00 07 t e s t i n g 00 00 00 0B c o n d i t i o n a l\" to #{{'SSH_MSG_MOCK' => 168, 'data' => 'testing', 'testing data' => 'conditional'}.inspect}" do
        expect( mixed_in.decode( ["A8", "00000007", "testing", "0000000B", "conditional"].pack("H*H*a*H*a*") ) ).to eq( {'SSH_MSG_MOCK' => 168, 'data' => 'testing', 'testing data' => 'conditional'} )
      end
    end
  end
end
