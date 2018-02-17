# coding: utf-8
# vim: et ts=2 sw=2

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
      it "has sequence_number 1 when called once" do
        sequence_number.increment
        expect( sequence_number.sequence_number ).to eq 1
      end

      it "has sequence_number 100000 when called 100000 times" do
        100000.times do
          sequence_number.increment
        end
        expect( sequence_number.sequence_number ).to eq 100000
      end

      it "has sequence_number 2^32 - 1 when called 2 times when sequence_number is 2^32 - 3" do
        sequence_number.sequence_number = 2 ** 32 - 3
        2.times do
          sequence_number.increment
        end
        expect( sequence_number.sequence_number ).to eq 2 ** 32 - 1
      end
    end

    context 'Over 2^32' do
      it "has sequence_number 0 when called once when sequence_number is 2^32 - 1" do
        sequence_number.sequence_number = 2 ** 32 - 1
        1.times do
          sequence_number.increment
        end
        expect( sequence_number.sequence_number ).to eq 0
      end

      it "has sequence_number 1 when called 2 times when sequence_number is 2^32 - 1" do
        sequence_number.sequence_number = 2 ** 32 - 1
        2.times do
          sequence_number.increment
        end
        expect( sequence_number.sequence_number ).to eq 1
      end
    end
  end
end
