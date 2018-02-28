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
      context "with packet of payload \"testing\"" do
        let(:payload){ "testing" }

        it "increments outgoing sequence number" do
          expect { sender.send transport, payload }.to change { transport.outgoing_sequence_number.sequence_number }.from(0).to(1)
        end

        it "sends packet of packet length 20" do
          sender.send transport, payload
          io.pos = 0
          expect(io.read(4).unpack("N")[0]).to eq 20
        end

        it "sends packet of padding length 12" do
          sender.send transport, payload
          io.pos = 4
          expect(io.read(1).unpack("C")[0]).to eq 12
        end

        it "sends packet of payload \"testing\"" do
          sender.send transport, payload
          io.pos = 5
          expect(io.read(7).unpack("a*")[0]).to eq "testing"
        end

        it "sends packet of 12 bytes of padding" do
          sender.send transport, payload
          io.pos = 12
          io.read(12).each_char do |byte|
            expect(byte.unpack("C")[0]).to be_between(0x00, 0xff).inclusive
          end
        end

        it "sends no mac" do
          sender.send transport, payload
          io.pos = 24
          expect(io.read).to eq ""
        end
      end
    end
  end
end
