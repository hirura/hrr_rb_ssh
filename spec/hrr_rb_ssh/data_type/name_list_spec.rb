# coding: utf-8
# vim: et ts=2 sw=2

require 'stringio'

RSpec.describe HrrRbSsh::DataType::NameList do
  describe ".encode" do
    context "when arg is array of string value" do
      context "with length less than or equal to 0xffff_ffff" do
        [
          [],
          ["zlib"],
          ["zlib", "none"],
          #['ab', 'wxyz' * 0x3fff_ffff],
        ].each do |array|
          str                       = array.join(',')
          str_length                = str.length
          str_length_hex_str        = "%08x" % str_length
          str_length_hex_str_pretty = str_length_hex_str.each_char.each_slice(2).map(&:join).join(' ')
          str_pretty                = if str.length > 10 then str[0,10].each_char.to_a.join(' ') + ' ...' else str.each_char.to_a.join(' ') end
          encoded_pretty            = if str_pretty.empty? then str_length_hex_str_pretty else [str_length_hex_str_pretty, str_pretty].join(' ') end
          array_pretty              = if array.inspect.length > 16 then array.inspect[0,16] + ' ...' else array.inspect end

          it "encodes #{array_pretty.ljust(20, ' ')} to #{"\"%s\"" % encoded_pretty}" do
            expect(HrrRbSsh::DataType::NameList.encode array).to eq ([str_length_hex_str].pack("H*") + str)
          end
        end
      end

      context "with length greater than 0xffff_ffff" do
        it "encodes name-list with length longer than 0xffff_ffff (0xffff_ffff + 1) with error" do
          array_mock = double('array mock that join method returns string_mock')
          string_mock = double('string mock with length (0xffff_ffff + 1)')

          expect(array_mock).to receive(:kind_of?).with(Array).and_return(true).once
          expect(array_mock).to receive(:map).with(any_args).and_return([::String]).once
          expect(array_mock).to receive(:join).with(',').and_return(string_mock).once
          expect(string_mock).to receive(:length).with(no_args).and_return(0xffff_ffff + 1).twice

          expect { HrrRbSsh::DataType::NameList.encode array_mock }.to raise_error ArgumentError
        end
      end
    end

    context "when arg is not array value" do
      [
        0,
        1,
        '0',
        '1',
        "string",
        false,
        true,
        {},
        Object,
      ].each do |value|
        value_pretty = value.inspect.ljust(8, ' ')

        it "encodes #{value_pretty} with error" do
          expect { HrrRbSsh::DataType::NameList.encode value }.to raise_error ArgumentError
        end
      end
    end

    context "when arg array contains not string value" do
      [
        [0],
        [1],
        [false],
        [true],
        [{}],
        [Object],
        [0, '0'],
        [1, '1'],
        [2, "string"],
        [false, "string"],
        [true, "string"],
        [{}, "string"],
        [Object, "string"],
        ['0', 0],
        ['1', 1],
        ["string", 2],
        ["string", false],
        ["string", true],
        ["string", {}],
        ["string", Object],
      ].each do |value|
        value_pretty = value.inspect.ljust(18, ' ')

        it "encodes #{value_pretty} with error" do
          expect { HrrRbSsh::DataType::NameList.encode value }.to raise_error ArgumentError
        end
      end
    end
  end

  describe ".decode" do
    [
      [],
      ["zlib"],
      ["zlib", "none"],
      #['ab', 'wxyz' * 0x3fff_ffff],
    ].each do |array|
      str                       = array.join(',')
      str_length                = str.length
      str_length_hex_str        = "%08x" % str_length
      str_length_hex_str_pretty = str_length_hex_str.each_char.each_slice(2).map(&:join).join(' ')
      str_pretty                = if str.length > 10 then str[0,10].each_char.to_a.join(' ') + ' ...' else str.each_char.to_a.join(' ') end
      encoded_pretty            = if str_pretty.empty? then str_length_hex_str_pretty else [str_length_hex_str_pretty, str_pretty].join(' ') end
      array_pretty              = if array.inspect.length > 16 then array.inspect[0,16] + ' ...' else array.inspect end

      it "decodes #{("\"%s\"" % encoded_pretty).ljust(37, ' ')} to #{array_pretty}" do
        io = StringIO.new ([str_length_hex_str].pack("H*") + str), 'r'
        expect(HrrRbSsh::DataType::NameList.decode io).to eq array
      end
    end
  end
end
