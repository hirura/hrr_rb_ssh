# coding: utf-8
# vim: et ts=2 sw=2

require 'stringio'

RSpec.describe HrrRbSsh::DataType do
  describe HrrRbSsh::DataType::Byte do
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
            expect(HrrRbSsh::DataType::Byte.encode hex_str.hex).to eq [hex_str].pack("H*")
          end
        end
      end

      context "when arg is not within byte value" do
        [
          -1,
          256,
        ].each do |int|
          it "encodes #{"%3d" % int} with error" do
            expect { HrrRbSsh::DataType::Byte.encode int }.to raise_error RuntimeError
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
          expect(HrrRbSsh::DataType::Byte.decode io).to eq hex_str.hex
        end
      end
    end
  end

  describe HrrRbSsh::DataType::Boolean do
    describe ".encode" do
      [
        [false, "00"],
        [true,  "01"],
      ].each do |boolean, hex_str|
        hex_str_pretty = "0x" + hex_str

        context "when arg is #{boolean} value" do
          it "encodes true to #{hex_str_pretty}" do
            expect(HrrRbSsh::DataType::Boolean.encode boolean).to eq [hex_str].pack("H*")
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
            expect { HrrRbSsh::DataType::Boolean.encode value }.to raise_error RuntimeError
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
            expect(HrrRbSsh::DataType::Boolean.decode io).to be boolean
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
            expect(HrrRbSsh::DataType::Boolean.decode io).to be boolean
          end
        end
      end
    end
  end

  describe HrrRbSsh::DataType::Uint32 do
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
          expect { HrrRbSsh::DataType::Uint32.encode (0x0000_0000 - 1) }.to raise_error RuntimeError
        end

        it "encodes (0xffff_ffff + 1) with error" do
          expect { HrrRbSsh::DataType::Uint32.encode (0xffff_ffff + 1) }.to raise_error RuntimeError
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

  describe HrrRbSsh::DataType::Uint64 do
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
            expect(HrrRbSsh::DataType::Uint64.encode hex_str.hex).to eq [hex_str].pack("H*")
          end
        end
      end

      context "when arg is not within uint64 value" do
        it "encodes (0x0000_0000_0000_0000 - 1) with error" do
          expect { HrrRbSsh::DataType::Uint64.encode (0x0000_0000_0000_0000 - 1) }.to raise_error RuntimeError
        end

        it "encodes (0xffff_ffff_ffff_ffff + 1) with error" do
          expect { HrrRbSsh::DataType::Uint64.encode (0xffff_ffff_ffff_ffff + 1) }.to raise_error RuntimeError
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
          expect(HrrRbSsh::DataType::Uint64.decode io).to eq hex_str.hex
        end
      end
    end
  end

  describe HrrRbSsh::DataType::String do
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
              expect(HrrRbSsh::DataType::String.encode str).to eq ([str_length_hex_str].pack("H*") + str)
            end
          end
        end

        context "with length greater than 0xffff_ffff" do
          it "encodes string with length longer than 0xffff_ffff (0xffff_ffff + 1) with error" do
            str_mock = double('str mock with length (0xffff_ffff + 1)')

            expect(str_mock).to receive(:kind_of?).with(::String).and_return(true).once
            expect(str_mock).to receive(:length).with(no_args).and_return(0xffff_ffff + 1).once

            expect { HrrRbSsh::DataType::String.encode str_mock }.to raise_error RuntimeError
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
            expect { HrrRbSsh::DataType::String.encode value }.to raise_error RuntimeError
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
          expect(HrrRbSsh::DataType::String.decode io).to eq str
        end
      end
    end
  end

  describe HrrRbSsh::DataType::Mpint do
    describe ".encode" do
      context "when arg is within mpint value" do
        [
          ["0",               "00" "00" "00" "00"                                        ],
          ["1",               "00" "00" "00" "01" "01"                                   ],
          ["9a378f9b2e332a7", "00" "00" "00" "08" "09" "a3" "78" "f9" "b2" "e3" "32" "a7"],
          ["80",              "00" "00" "00" "02" "00" "80"                              ],
          ["-1234",           "00" "00" "00" "02" "ed" "cc"                              ],
          ["-deadbeef",       "00" "00" "00" "05" "ff" "21" "52" "41" "11"               ],
        ].each do |hex_str, hex_rpr|
          hex_rpr_pretty = hex_rpr.each_char.each_slice(2).map(&:join).join(' ')

          it "encodes #{hex_str.ljust(15, ' ')} to #{hex_rpr_pretty}" do
            expect(HrrRbSsh::DataType::Mpint.encode hex_str.hex).to eq [hex_rpr].pack("H*")
          end
        end
      end

      context "when arg is not within mpint value" do
        it "encodes (1 << ((8 * 0xffff_ffff) + 1)); requires 0xffff_ffff + 1 bytes; with error" do
          #expect { HrrRbSsh::DataType::Mpint.encode (1 << ((8 * 0xffff_ffff) + 1)) }.to raise_error RuntimeError
        end
      end
    end

    describe ".decode" do
      [
        ["00" "00" "00" "00",                                         "0"              ],
        ["00" "00" "00" "01" "01",                                    "1"              ],
        ["00" "00" "00" "08" "09" "a3" "78" "f9" "b2" "e3" "32" "a7", "9a378f9b2e332a7"],
        ["00" "00" "00" "02" "00" "80",                               "80"             ],
        ["00" "00" "00" "02" "ed" "cc",                               "-1234"          ],
        ["00" "00" "00" "05" "ff" "21" "52" "41" "11",                "-deadbeef"      ],
      ].each do |hex_rpr, hex_str|
        hex_rpr_pretty = hex_rpr.each_char.each_slice(2).map(&:join).join(' ')

        it "decodes #{hex_rpr_pretty.ljust(35, ' ')} to #{hex_str}" do
          io = StringIO.new [hex_rpr].pack("H*"), 'r'
          expect(HrrRbSsh::DataType::Mpint.decode io).to eq hex_str.hex
        end
      end
    end
  end

  describe HrrRbSsh::DataType::NameList do
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
            expect(string_mock).to receive(:length).with(no_args).and_return(0xffff_ffff + 1).once

            expect { HrrRbSsh::DataType::NameList.encode array_mock }.to raise_error RuntimeError
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
            expect { HrrRbSsh::DataType::NameList.encode value }.to raise_error RuntimeError
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
            expect { HrrRbSsh::DataType::NameList.encode value }.to raise_error RuntimeError
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
end
