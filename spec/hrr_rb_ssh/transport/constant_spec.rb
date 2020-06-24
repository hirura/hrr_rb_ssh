RSpec.describe HrrRbSsh::Transport::Constant do
  let(:cr){ 0x0d.chr }
  let(:lf){ 0x0a.chr }

  it "has CR defined" do
    expect(described_class::CR).to eq cr
  end

  it "has LF defined" do
    expect(described_class::LF).to eq lf
  end
end
