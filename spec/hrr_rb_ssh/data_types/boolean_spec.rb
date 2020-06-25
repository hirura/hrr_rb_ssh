RSpec.describe HrrRbSsh::DataTypes::Boolean do
  describe ".encode" do
    [
      [false, "00"],
      [true,  "01"],
    ].each do |boolean, hex_str|
      hex_str_pretty = "0x" + hex_str

      context "when arg is #{boolean} value" do
        it "encodes true to #{hex_str_pretty}" do
          expect(HrrRbSsh::DataTypes::Boolean.encode boolean).to eq [hex_str].pack("H*")
        end
      end
    end

    context "when arg is neither true nor false value" do
      [
        0,
        1,
        '0',
        '1',
        'string',
        Object,
      ].each do |value|
        value_pretty = value.inspect.ljust(8, ' ')

        it "encodes #{value_pretty} with error" do
          expect { HrrRbSsh::DataTypes::Boolean.encode value }.to raise_error ArgumentError
        end
      end
    end
  end

  describe ".decode" do
    context "when arg is 0x00 value" do
      [
        ["00", false],
      ].each do |hex_str, boolean|
        hex_str_pretty = "0x" + hex_str

        it "decodes #{hex_str_pretty} to #{boolean}" do
          io = StringIO.new [hex_str].pack("H*"), 'r'
          expect(HrrRbSsh::DataTypes::Boolean.decode io).to be boolean
        end
      end
    end

    context "when arg is not 0x00 value" do
      [
        ["01", true],
        ["0f", true],
        ["10", true],
        ["ff", true],
      ].each do |hex_str, boolean|
        hex_str_pretty = "0x" + hex_str

        it "decodes #{hex_str_pretty} to #{boolean}" do
          io = StringIO.new [hex_str].pack("H*"), 'r'
          expect(HrrRbSsh::DataTypes::Boolean.decode io).to be boolean
        end
      end
    end
  end
end
