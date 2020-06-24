require 'stringio'

RSpec.describe HrrRbSsh::DataTypes::String do
  describe ".encode" do
    context "when arg is string value" do
      context "with length less than or equal to 0xffff_ffff" do
        [
          "",
          "testing",
          #'abcd' * (0x3fff_ffff) + 'xyz',
        ].each do |str|
          str_length                = str.length
          str_length_hex_str        = "%08x" % str_length
          str_length_hex_str_pretty = str_length_hex_str.each_char.each_slice(2).map(&:join).join(' ')
          str_pretty                = if str.length > 10 then str[0,10].each_char.to_a.join(' ') + ' ...' else str.each_char.to_a.join(' ') end
          encoded_pretty            = if str_pretty.empty? then str_length_hex_str_pretty else [str_length_hex_str_pretty, str_pretty].join(' ') end

          it "encodes #{("\"%s\"" % (if str.length > 10 then str[0,10] + '...' else str end)).ljust(15, ' ')} to #{"\"%s\"" % encoded_pretty}" do
            expect(HrrRbSsh::DataTypes::String.encode str).to eq ([str_length_hex_str].pack("H*") + str)
          end
      end
    end

    context "with length greater than 0xffff_ffff" do
      it "encodes string with length longer than 0xffff_ffff (0xffff_ffff + 1) with error" do
        str_mock = double('str mock with length (0xffff_ffff + 1)')

        expect(str_mock).to receive(:kind_of?).with(::String).and_return(true).once
        expect(str_mock).to receive(:bytesize).with(no_args).and_return(0xffff_ffff + 1).twice

        expect { HrrRbSsh::DataTypes::String.encode str_mock }.to raise_error ArgumentError
      end
    end
  end

  context "when arg is not string value" do
    [
      0,
      false,
      true,
      [],
      {},
      Object,
    ].each do |value|
      value_pretty = value.inspect.ljust(6, ' ')

      it "encodes #{value_pretty} with error" do
        expect { HrrRbSsh::DataTypes::String.encode value }.to raise_error ArgumentError
      end
    end
  end
end

describe ".decode" do
  [
    "",
    "testing",
    #'abcd' * (0x3fff_ffff) + 'xyz',
  ].each do |str|
    str_length                = str.length
    str_length_hex_str        = "%08x" % str_length
    str_length_hex_str_pretty = str_length_hex_str.each_char.each_slice(2).map(&:join).join(' ')
    str_pretty                = if str.length > 10 then str[0,10].each_char.to_a.join(' ') + ' ...' else str.each_char.to_a.join(' ') end
    encoded_pretty            = if str_pretty.empty? then str_length_hex_str_pretty else [str_length_hex_str_pretty, str_pretty].join(' ') end

    it "decodes #{("\"%s\"" % encoded_pretty).ljust(37, ' ')} to #{"\"%s\"" % (if str.length > 10 then str[0,10] + '...' else str end)}" do
      io = StringIO.new ([str_length_hex_str].pack("H*") + str), 'r'
      expect(HrrRbSsh::DataTypes::String.decode io).to eq str
    end
end
    end
  end
