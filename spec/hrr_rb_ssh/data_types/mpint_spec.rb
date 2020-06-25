RSpec.describe HrrRbSsh::DataTypes::Mpint do
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
          expect(HrrRbSsh::DataTypes::Mpint.encode hex_str.hex).to eq [hex_rpr].pack("H*")
        end
      end
    end

    context "when arg is not Integer value" do
      let(:arg){ "string value" }

      it "raises ArgumentError" do
        expect { HrrRbSsh::DataTypes::Mpint.encode arg }.to raise_error ArgumentError
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
        expect(HrrRbSsh::DataTypes::Mpint.decode io).to eq hex_str.hex
      end
    end
  end
end
