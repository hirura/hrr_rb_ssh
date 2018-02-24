# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport::Packet do
  context "with initial transport" do
    let(:io){ 'dummy_io' }
    let(:mode){ HrrRbSsh::Transport::Mode::SERVER }
    let(:transport){ HrrRbSsh::Transport.new io, mode }

    describe ".new_from_payload" do
      let(:packet){ described_class.new_from_payload transport, payload }

      context "with payload \"testing\"" do
        let(:payload){ "testing" }

        it "has packet length 20" do
          expect(packet.packet_length).to eq 20
        end

        it "has padding length 12" do
          expect(packet.padding_length).to eq 12
        end

        it "has payload \"testing\"" do
          expect(packet.payload).to eq "testing"
        end

        it "has 12 byte values of padding" do
          packet.padding.each_char do |byte|
            expect(byte.unpack("C")[0]).to be_between(0x00, 0xff).inclusive
          end
        end

        it "has unencrypted packet constructed with packet length 20" do
          expect(packet.unencrypted[0,4].unpack("N")[0]).to eq 20
        end

        it "has unencrypted packet constructed with padding length 12" do
          expect(packet.unencrypted[4,1].unpack("C")[0]).to eq 12
        end

        it "has unencrypted packet constructed with payload \"testing\"" do
          expect(packet.unencrypted[5,7].unpack("a*")[0]).to eq "testing"
        end

        it "has unencrypted packet constructed with 12 byte values of padding" do
          packet.unencrypted[12,12].each_char do |byte|
            expect(byte.unpack("C")[0]).to be_between(0x00, 0xff).inclusive
          end
        end

        it "has encrypted packet constructed with packet length 20" do
          expect(packet.encrypted[0,4].unpack("N")[0]).to eq 20
        end

        it "has encrypted packet constructed with padding length 12" do
          expect(packet.encrypted[4,1].unpack("C")[0]).to eq 12
        end

        it "has encrypted packet constructed with payload \"testing\"" do
          expect(packet.encrypted[5,7].unpack("a*")[0]).to eq "testing"
        end

        it "has encrypted packet constructed with 12 byte values of padding" do
          packet.encrypted[12,12].each_char do |byte|
            expect(byte.unpack("C")[0]).to be_between(0x00, 0xff).inclusive
          end
        end
      end
    end

    describe ".new_from_encrypted_packet" do
      let(:packet){ described_class.new_from_encrypted_packet transport, encrypted_packet }

      context "with encrypted packet of payload \"testing\"" do
        let(:encrypted_packet){
          [
            "00000014",
            "0c",
            "testing",
            Array.new(12){ rand(256).to_s(16) }.join
          ].pack("H*" "H*" "a7" "H*")
        }

        it "has packet length 20" do
          expect(packet.packet_length).to eq 20
        end

        it "has padding length 12" do
          expect(packet.padding_length).to eq 12
        end

        it "has payload \"testing\"" do
          expect(packet.payload).to eq "testing"
        end

        it "has 12 byte values of padding" do
          packet.padding.each_char do |byte|
            expect(byte.unpack("C")[0]).to be_between(0x00, 0xff).inclusive
          end
        end

        it "has unencrypted packet constructed with packet length 20" do
          expect(packet.unencrypted[0,4].unpack("N")[0]).to eq 20
        end

        it "has unencrypted packet constructed with padding length 12" do
          expect(packet.unencrypted[4,1].unpack("C")[0]).to eq 12
        end

        it "has unencrypted packet constructed with payload \"testing\"" do
          expect(packet.unencrypted[5,7].unpack("a*")[0]).to eq "testing"
        end

        it "has unencrypted packet constructed with 12 byte values of padding" do
          packet.unencrypted[12,12].each_char do |byte|
            expect(byte.unpack("C")[0]).to be_between(0x00, 0xff).inclusive
          end
        end

        it "has encrypted packet constructed with packet length 20" do
          expect(packet.encrypted[0,4].unpack("N")[0]).to eq 20
        end

        it "has encrypted packet constructed with padding length 12" do
          expect(packet.encrypted[4,1].unpack("C")[0]).to eq 12
        end

        it "has encrypted packet constructed with payload \"testing\"" do
          expect(packet.encrypted[5,7].unpack("a*")[0]).to eq "testing"
        end

        it "has encrypted packet constructed with 12 byte values of padding" do
          packet.encrypted[12,12].each_char do |byte|
            expect(byte.unpack("C")[0]).to be_between(0x00, 0xff).inclusive
          end
        end
      end
    end
  end
end
