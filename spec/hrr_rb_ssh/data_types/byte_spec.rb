# coding: utf-8
# vim: et ts=2 sw=2

require 'stringio'

RSpec.describe HrrRbSsh::DataTypes::Byte do
  describe ".encode" do
    context "when arg is within byte value" do
      [
        "00",
        "01",
        "0f",
        "10",
        "ff",
      ].each do |hex_str|
        hex_str_pretty = "0x" + hex_str

        it "encodes #{"%3d" % hex_str.hex} to #{hex_str_pretty}" do
          expect(HrrRbSsh::DataTypes::Byte.encode hex_str.hex).to eq [hex_str].pack("H*")
        end
      end
    end

    context "when arg is not within byte value" do
      [
        -1,
        256,
      ].each do |int|
        it "encodes #{"%3d" % int} with error" do
          expect { HrrRbSsh::DataTypes::Byte.encode int }.to raise_error ArgumentError
        end
      end
    end
  end

  describe ".decode" do
    [
      "00",
      "01",
      "0f",
      "10",
      "ff",
    ].each do |hex_str|
      hex_str_pretty = "0x" + hex_str

      it "decodes #{hex_str_pretty} to #{"%3d" % hex_str.hex}" do
        io = StringIO.new [hex_str].pack("H*"), 'r'
        expect(HrrRbSsh::DataTypes::Byte.decode io).to eq hex_str.hex
      end
    end
  end
end
