RSpec.describe HrrRbSsh::Mode do
  let(:server){ :server }
  let(:client){ :client }

  it "has SERVER" do
    expect(described_class::SERVER).to eq :server
  end

  it "has CLIENT" do
    expect(described_class::CLIENT).to eq :client
  end
end
