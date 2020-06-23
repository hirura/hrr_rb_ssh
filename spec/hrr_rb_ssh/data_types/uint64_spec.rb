# coding: utf-8
# vim: et ts=2 sw=2

require 'stringio'

RSpec.describe HrrRbSsh::DataTypes::Uint64 do
  describe ".encode" do
    context "when arg is within uint64 value" do
      [
        "0000" "0000" "0000" "0000",
        "0000" "0000" "0000" "0001",
        "0000" "0000" "ffff" "ffff",
        "0000" "0001" "0000" "0000",
        "ffff" "ffff" "ffff" "ffff",
      ].each do |hex_str|
        hex_str_pretty = "0x" + hex_str.each_char.each_slice(4).map(&:join).join('_')

        it "encodes #{"%20d" % hex_str.hex} to #{hex_str_pretty}" do
          expect(HrrRbSsh::DataTypes::Uint64.encode hex_str.hex).to eq [hex_str].pack("H*")
        end
      end
    end

    context "when arg is not within uint64 value" do
      it "encodes (0x0000_0000_0000_0000 - 1) with error" do
        expect { HrrRbSsh::DataTypes::Uint64.encode (0x0000_0000_0000_0000 - 1) }.to raise_error ArgumentError
      end

      it "encodes (0xffff_ffff_ffff_ffff + 1) with error" do
        expect { HrrRbSsh::DataTypes::Uint64.encode (0xffff_ffff_ffff_ffff + 1) }.to raise_error ArgumentError
      end
    end
  end

  describe ".decode" do
    [
      "0000" "0000" "0000" "0000",
      "0000" "0000" "0000" "0001",
      "0000" "0000" "ffff" "ffff",
      "0000" "0001" "0000" "0000",
      "ffff" "ffff" "ffff" "ffff",
    ].each do |hex_str|
      hex_str_pretty = "0x" + hex_str.each_char.each_slice(4).map(&:join).join('_')

      it "decodes #{hex_str_pretty} to #{"%20d" % hex_str.hex}" do
        io = StringIO.new [hex_str].pack("H*"), 'r'
        expect(HrrRbSsh::DataTypes::Uint64.decode io).to eq hex_str.hex
      end
    end
  end
end
