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
          ['byte',   'message number'],
          ['string', 'data'        ],
        ]
      end
    end

    let(:mixed_in){
      SSH_MSG_MOCK_WITH_NO_CONDITIONAL_DEFINITION
    }

    describe ".encode" do
      context "when arg does not contain an instance of Proc" do
        it "encodes #{{'message number' => 168, 'data' => 'testing'}.inspect} to \"A8 00 00 00 07 t e s t i n g\"" do
          expect( mixed_in.encode( {'message number' => 168, 'data' => 'testing'} ) ).to eq( ["A8", "00000007", "testing"].pack("H*H*a*") )
        end
      end

      context "when arg contains an instance of Proc" do
        it "encodes #{{'message number' => 168, 'data' => lambda { 'testing' }}.inspect} to \"A8 00 00 00 07 t e s t i n g\"" do
          expect( mixed_in.encode( {'message number' => 168, 'data' => lambda { 'testing' }} ) ).to eq( ["A8", "00000007", "testing"].pack("H*H*a*") )
        end
      end
    end

    describe ".decode" do
      it "decodes \"A8 00 00 00 07 t e s t i n g\" to #{{'message number' => 168, 'data' => 'testing'}.inspect}" do
        expect( mixed_in.decode( ["A8", "00000007", "testing"].pack("H*H*a*") ) ).to eq( {'message number' => 168, 'data' => 'testing'} )
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
          ['byte',   'message number'],
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
        it "encodes #{{'message number' => 168, 'data' => 'testing', 'testing data' => 'conditional'}.inspect} to \"A8 00 00 00 07 t e s t i n g 00 00 00 0B c o n d i t i o n a l\"" do
          expect( mixed_in.encode( {'message number' => 168, 'data' => 'testing', 'testing data' => 'conditional'} ) ).to eq( ["A8", "00000007", "testing", "0000000B", "conditional"].pack("H*H*a*H*a*") )
        end
      end

      context "when arg contains an instance of Proc" do
        it "encodes #{{'message number' => 168, 'data' => lambda { 'testing' }, 'testing data' => lambda { 'conditional' }}.inspect} to \"A8 00 00 00 07 t e s t i n g 00 00 00 0B c o n d i t i o n a l\"" do
          expect( mixed_in.encode( {'message number' => 168, 'data' => lambda { 'testing' }, 'testing data' => lambda { 'conditional' }} ) ).to eq( ["A8", "00000007", "testing", "0000000B", "conditional"].pack("H*H*a*H*a*") )
        end
      end
    end

    describe ".decode" do
      it "decodes \"A8 00 00 00 07 t e s t i n g 00 00 00 0B c o n d i t i o n a l\" to #{{'message number' => 168, 'data' => 'testing', 'testing data' => 'conditional'}.inspect}" do
        expect( mixed_in.decode( ["A8", "00000007", "testing", "0000000B", "conditional"].pack("H*H*a*H*a*") ) ).to eq( {'message number' => 168, 'data' => 'testing', 'testing data' => 'conditional'} )
      end
    end
  end

  context "when module has chained CONDITIONAL_DEFINITION" do
    before :context do
      module SSH_MSG_MOCK_WITH_CHAINED_CONDITIONAL_DEFINITION
        class << self
          include HrrRbSsh::Message::Codable
        end

        DEFINITION = [
          ['byte',   'message number'],
          ['string', 'data'        ],
        ]

        TESTING_DEFINITION = [
          ['string', 'testing data'],
        ]

        CHAINED_DEFINITION = [
          ['string', 'chained data'],
        ]

        CONDITIONAL_DEFINITION = {
          'data' => {
            'testing' => TESTING_DEFINITION,
          },
          'testing data' => {
            'conditional' => CHAINED_DEFINITION,
          },
        }
      end
    end

    let(:mixed_in){
      SSH_MSG_MOCK_WITH_CHAINED_CONDITIONAL_DEFINITION
    }

    describe ".encode" do
      context "when arg does not contain an instance of Proc" do
        it "encodes #{{'message number' => 168, 'data' => 'testing', 'testing data' => 'conditional', 'chained data' => 'chained'}.inspect} to \"A8 00 00 00 07 t e s t i n g 00 00 00 0B c o n d i t i o n a l 00 00 00 07 c h a i n e d\"" do
          expect( mixed_in.encode( {'message number' => 168, 'data' => 'testing', 'testing data' => 'conditional', 'chained data' => 'chained'} ) ).to eq( ["A8", "00000007", "testing", "0000000B", "conditional", "00000007", "chained"].pack("H*H*a*H*a*H*a*") )
        end
      end

      context "when arg contains an instance of Proc" do
        it "encodes #{{'message number' => 168, 'data' => lambda { 'testing' }, 'testing data' => lambda { 'conditional' }, 'chained data' => lambda { 'chained' }}.inspect} to \"A8 00 00 00 07 t e s t i n g 00 00 00 0B c o n d i t i o n a l 00 00 00 07 c h a i n e d\"" do
          expect( mixed_in.encode( {'message number' => 168, 'data' => lambda { 'testing' }, 'testing data' => lambda { 'conditional' }, 'chained data' => lambda { 'chained' }} ) ).to eq( ["A8", "00000007", "testing", "0000000B", "conditional", "00000007", "chained"].pack("H*H*a*H*a*H*a*") )
        end
      end
    end

    describe ".decode" do
      it "decodes \"A8 00 00 00 07 t e s t i n g 00 00 00 0B c o n d i t i o n a l 00 00 00 07 c h a i n e d\" to #{{'message number' => 168, 'data' => 'testing', 'testing data' => 'conditional', 'chained data' => 'chained'}.inspect}" do
        expect( mixed_in.decode( ["A8", "00000007", "testing", "0000000B", "conditional", "00000007", "chained"].pack("H*H*a*H*a*H*a*") ) ).to eq( {'message number' => 168, 'data' => 'testing', 'testing data' => 'conditional', 'chained data' => 'chained'} )
      end
    end
  end

  context "when module has CONDITIONAL_DEFINITION that requires complementary message" do
    before :context do
      module SSH_MSG_MOCK_WITH_HIDDEN_CONDITIONAL_DEFINITION
        class << self
          include HrrRbSsh::Message::Codable
        end

        DEFINITION = [
          ['byte',   'message number'],
          ['string', 'data'        ],
        ]

        HIDDEN_DEFINITION = [
          ['string', 'hidden data'],
        ]

        CONDITIONAL_DEFINITION = {
          'require hidden' => {
            true => HIDDEN_DEFINITION,
          },
        }
      end
    end

    let(:mixed_in){
      SSH_MSG_MOCK_WITH_HIDDEN_CONDITIONAL_DEFINITION
    }

    describe ".encode" do
      context "when arg does not contain an instance of Proc" do
        it "encodes #{{'message number' => 168, 'data' => 'testing', 'hidden data' => 'conditional'}.inspect} with complementary message #{{'require hidden' => true}.inspect} to \"A8 00 00 00 07 t e s t i n g 00 00 00 0B c o n d i t i o n a l\"" do
          expect( mixed_in.encode( {'message number' => 168, 'data' => 'testing', 'hidden data' => 'conditional'}, {'require hidden' => true} ) ).to eq( ["A8", "00000007", "testing", "0000000B", "conditional"].pack("H*H*a*H*a*") )
        end
      end

      context "when arg contains an instance of Proc" do
        it "encodes #{{'message number' => 168, 'data' => lambda { 'testing' }, 'hidden data' => lambda { 'conditional' }}.inspect} with complementary message #{{'require hidden' => lambda { true }}.inspect} to \"A8 00 00 00 07 t e s t i n g 00 00 00 0B c o n d i t i o n a l\"" do
          expect( mixed_in.encode( {'message number' => 168, 'data' => lambda { 'testing' }, 'hidden data' => lambda { 'conditional' }}, {'require hidden' => lambda { true }} ) ).to eq( ["A8", "00000007", "testing", "0000000B", "conditional"].pack("H*H*a*H*a*") )
        end
      end
    end

    describe ".decode" do
      it "decodes \"A8 00 00 00 07 t e s t i n g 00 00 00 0B c o n d i t i o n a l\" with complementary message #{{'require hidden' => true}.inspect} to #{{'message number' => 168, 'data' => 'testing', 'hidden data' => 'conditional'}.inspect}" do
        expect( mixed_in.decode( ["A8", "00000007", "testing", "0000000B", "conditional"].pack("H*H*a*H*a*"), {'require hidden' => true} ) ).to eq( {'message number' => 168, 'data' => 'testing', 'hidden data' => 'conditional'} )
      end
    end
  end
end
