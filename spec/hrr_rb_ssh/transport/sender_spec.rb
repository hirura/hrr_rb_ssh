# coding: utf-8
# vim: et ts=2 sw=2

require 'stringio'

RSpec.describe HrrRbSsh::Transport::Sender do
  let(:sender){ described_class.new }

  context "with initial transport" do
    let(:io){ StringIO.new String.new, 'r+' }
    let(:mode){ HrrRbSsh::Transport::Mode::SERVER }
    let(:transport){ HrrRbSsh::Transport.new io, mode }

    describe "#send" do
      context "with packet with payload \"testing\"" do
        let(:payload){ "testing" }
        let(:packet){ HrrRbSsh::Transport::Packet.new_from_payload transport, payload }

        it "increments outgoing sequence number" do
          expect { sender.send transport, packet }.to change { transport.outgoing_sequence_number.sequence_number }.from(0).to(1)
        end

        it "sends encrypted packet stored in packet instance" do
          sender.send transport, packet
          io.rewind
          expect(io.read(packet.encrypted.length)).to eq packet.encrypted
        end

        it "sends no mac" do
          sender.send transport, packet
          io.pos = (packet.encrypted.length)
          expect(io.read).to eq ""
        end
      end
    end
  end
end
