# coding: utf-8
# vim: et ts=2 sw=2

require 'stringio'

RSpec.describe HrrRbSsh::Transport::Receiver do
  let(:receiver){ described_class.new }

  context "with initial transport" do
    let(:io){ StringIO.new String.new, 'r+' }
    let(:mode){ HrrRbSsh::Mode::SERVER }
    let(:transport){ HrrRbSsh::Transport.new io, mode }

    describe "#receive" do
      let(:packet){
        [
          "00000014",
          "0c",
          "testing",
          "#{Array.new(12){ "%02x" % rand(256) }.join}",
        ].pack("H*" "H*" "a7" "H*")
      }

      context "with packet of payload \"testing\"" do
        before :example do
          io.write packet
          io.rewind
        end

        it "increments incoming sequence number" do
          expect(transport.incoming_sequence_number.sequence_number).to eq 0
          receiver.receive transport
          expect(transport.incoming_sequence_number.sequence_number).to eq 1
        end

        it "returns payload \"testing\"" do
          expect(receiver.receive transport).to eq "testing"
        end

        it "reads all" do
          receiver.receive transport
          expect(io.pos).to eq packet.length
        end
      end

      context "when IO is EOF" do
        context "before receiving first block" do
          before :example do
            io.write packet[0, 0]
            io.rewind
          end

          it "raises EOFError" do
            expect { receiver.receive transport }.to raise_error EOFError
          end
        end

        context "in first block" do
          before :example do
            io.write packet[0, 1]
            io.rewind
          end

          it "raises EOFError" do
            expect { receiver.receive transport }.to raise_error EOFError
          end
        end

        context "before receiving last block" do
          before :example do
            block_size = [transport.instance_variable_get('@incoming_encryption_algorithm').block_size, 8].max
            io.write packet[0, block_size]
            io.rewind
          end

          it "raises EOFError" do
            expect { receiver.receive transport }.to raise_error EOFError
          end
        end

        context "in last block" do
          before :example do
            block_size = [transport.instance_variable_get('@incoming_encryption_algorithm').block_size, 8].max
            io.write packet[0, block_size+1]
            io.rewind
          end

          it "raises EOFError" do
            expect { receiver.receive transport }.to raise_error EOFError
          end
        end

        context "before receiving mac" do
          before :example do
            io.write packet[0, packet.length]
            io.rewind
          end

          it "raises EOFError" do
            allow(transport.incoming_mac_algorithm).to receive(:digest_length).and_return(20)
            expect { receiver.receive transport }.to raise_error EOFError
          end
        end

        context "in mac" do
          before :example do
            io.write packet[0, packet.length]
            io.write 'shortage mac'
            io.rewind
          end

          it "raises EOFError" do
            allow(transport.incoming_mac_algorithm).to receive(:digest_length).and_return(20)
            expect { receiver.receive transport }.to raise_error EOFError
          end
        end
      end
    end
  end
end
