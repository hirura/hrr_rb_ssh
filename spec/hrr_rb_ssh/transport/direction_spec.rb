RSpec.describe HrrRbSsh::Transport::Direction do
  let(:outgoing){ :outgoing }
  let(:incoming){ :incoming }

  it "has OUTGOING" do
    expect(described_class::OUTGOING).to eq outgoing
  end

  it "has INCOMING" do
    expect(described_class::INCOMING).to eq incoming
  end
end
