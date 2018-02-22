# coding: utf-8
# vim: et ts=2 sw=2

require 'stringio'

RSpec.describe HrrRbSsh::Transport::Sender do
  let(:sender){ described_class.new transport }

  context "with initial transport" do
    let(:io){ StringIO.new String.new, 'r+' }
    let(:mode){ HrrRbSsh::Transport::Mode::SERVER }
    let(:transport){ HrrRbSsh::Transport.new io, mode }

    describe "#packetize" do
      let(:packet){ sender.packetize payload }

      context "with payload \"testing\"" do
        let(:payload){ "testing" }

        it "returns packet length 20" do
          expect(packet[0,4].unpack("N")[0]).to eq 20
        end

        it "returns padding length 12" do
          expect(packet[4,1].unpack("C")[0]).to eq 12
        end

        it "returns payload \"testing\"" do
          expect(packet[5,7].unpack("a*")[0]).to eq "testing"
        end

        it "returns 12 byte values of padding" do
          packet[12,12].each_char do |byte|
            expect(byte.unpack("C")[0]).to be_between(0x00, 0xff).inclusive
          end
        end

        it "returns no mac" do
          expect(packet[24..-1]).to eq ""
        end
      end
    end

    describe "#send" do
      context "with payload \"testing\"" do
        let(:payload){ "testing" }

        it "increments outgoing sequence number" do
          expect { sender.send payload }.to change { transport.outgoing_sequence_number.sequence_number }.from(0).to(1)
        end

        it "sends packet with packet length 20" do
          sender.send payload
          io.pos = 0
          expect(io.read(4).unpack("N")[0]).to eq 20
        end

        it "sends packet with padding length 12" do
          sender.send payload
          io.pos = 4
          expect(io.read(1).unpack("C")[0]).to eq 12
        end

        it "sends packet with payload \"testing\"" do
          sender.send payload
          io.pos = 5
          expect(io.read(7).unpack("a*")[0]).to eq "testing"
        end

        it "sends packet with 12 byte values of padding" do
          sender.send payload
          io.pos = 12
          12.times do
            expect(io.read(1).unpack("C")[0]).to be_between(0x00, 0xff).inclusive
          end
        end

        it "sends packet with no mac" do
          sender.send payload
          io.pos = 24
          expect(io.read).to eq ""
        end
      end
    end
  end
end
