# coding: utf-8
# vim: et ts=2 sw=2

require 'stringio'

RSpec.describe HrrRbSsh::Transport::Receiver do
  let(:receiver){ described_class.new }

  context "with initial transport" do
    let(:io){ StringIO.new String.new, 'r+' }
    let(:mode){ HrrRbSsh::Transport::Mode::SERVER }
    let(:transport){ HrrRbSsh::Transport.new io, mode }

    describe "#receive" do
      context "with packet of payload \"testing\"" do
        let(:packet){
          [
            "00000014",
            "0c",
            "testing",
            "#{Array.new(12){ rand(256).to_s(16) }.join}",
          ].pack("H*" "H*" "a7" "H*")
        }

        it "increments incoming sequence number" do
          io.write packet
          io.rewind
          expect { receiver.receive transport }.to change { transport.incoming_sequence_number.sequence_number }.from(0).to(1)
        end

        it "returns payload \"testing\"" do
          io.write packet
          io.rewind
          expect(receiver.receive transport).to eq "testing"
        end

        it "reads all" do
          io.write packet
          io.rewind
          receiver.receive transport
          expect(io.read).to eq ""
        end
      end
    end
  end
end
