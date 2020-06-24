RSpec.describe HrrRbSsh::Transport::SequenceNumber do
  let(:sequence_number){ HrrRbSsh::Transport::SequenceNumber.new }

  describe '#initialize' do
    it "takes no arguments" do
      expect { HrrRbSsh::Transport::SequenceNumber.new }.not_to raise_error
    end

    it "has sequence_number 0 at first" do
      expect( sequence_number.sequence_number ).to eq 0
    end
  end

  describe '#increment' do
    before do
      class HrrRbSsh::Transport::SequenceNumber
        def sequence_number= sequence_number
          @sequence_number = sequence_number
        end
      end
    end

    context 'Until 2^32' do
      it "is changed from 0 to 1 when called once" do
        expect { sequence_number.increment }.to change { sequence_number.sequence_number }.from( 0 ).to( 1 )
      end

      it "is changed from 0 to 100000 when called 100000 times" do
        expect {
          100000.times do
            sequence_number.increment
          end
        }.to change { sequence_number.sequence_number }.from( 0 ).to( 100000 )
      end

      it "is changed from 2^32 - 3 to 2^32 - 1 when called 2 times" do
        sequence_number.sequence_number = 2 ** 32 - 3
        expect {
          2.times do
            sequence_number.increment
          end
        }.to change { sequence_number.sequence_number }.from( 2 ** 32 - 3 ).to( 2 ** 32 - 1 )
      end
    end

    context 'Over 2^32' do
      it "is changed from 2^32 - 1 to 0 when called once" do
        sequence_number.sequence_number = 2 ** 32 - 1
        expect {
          1.times do
            sequence_number.increment
          end
        }.to change { sequence_number.sequence_number }.from( 2 ** 32 - 1 ).to( 0 )
      end

      it "is changed from 2^32 - 1 to 1 when called 2 times" do
        sequence_number.sequence_number = 2 ** 32 - 1
        expect {
          2.times do
            sequence_number.increment
          end
        }.to change { sequence_number.sequence_number }.from( 2 ** 32 - 1 ).to( 1 )
      end
    end
  end
end
