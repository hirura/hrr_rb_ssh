# coding: utf-8
# vim: et ts=2 sw=2

require 'stringio'

RSpec.describe HrrRbSsh::DataType::Uint32 do
  describe ".encode" do
    context "when arg is within uint32 value" do
      [
        "0000" "0000",
        "0000" "0001",
        "0000" "ffff",
        "0001" "0000",
        "ffff" "ffff",
      ].each do |hex_str|
        hex_str_pretty = "0x" + hex_str.each_char.each_slice(4).map(&:join).join('_')

        it "encodes #{"%10d" % hex_str.hex} to #{hex_str_pretty}" do
          expect(HrrRbSsh::DataType::Uint32.encode hex_str.hex).to eq [hex_str].pack("H*")
        end
      end
    end

    context "when arg is not within uint32 value" do
      it "encodes (0x0000_0000 - 1) with error" do
        expect { HrrRbSsh::DataType::Uint32.encode (0x0000_0000 - 1) }.to raise_error ArgumentError
      end

      it "encodes (0xffff_ffff + 1) with error" do
        expect { HrrRbSsh::DataType::Uint32.encode (0xffff_ffff + 1) }.to raise_error ArgumentError
      end
    end
  end

  describe ".decode" do
    [
      "0000" "0000",
      "0000" "0001",
      "0000" "ffff",
      "0001" "0000",
      "ffff" "ffff",
    ].each do |hex_str|
      hex_str_pretty = "0x" + hex_str.each_char.each_slice(4).map(&:join).join('_')

      it "decodes #{hex_str_pretty} to #{"%10d" % hex_str.hex}" do
        io = StringIO.new [hex_str].pack("H*"), 'r'
        expect(HrrRbSsh::DataType::Uint32.decode io).to eq hex_str.hex
      end
    end
  end
end
