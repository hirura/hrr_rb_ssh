# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport::MacAlgorithm::None do
  let(:mac_algorithm){ HrrRbSsh::Transport::MacAlgorithm::None.new }
  let(:transport){ "dummy transport" }
  let(:packet){ "dummy packet" }

  it "is registered as none in HrrRbSsh::Transport::MacAlgorithm.list" do
    expect( HrrRbSsh::Transport::MacAlgorithm['none'] ).to eq HrrRbSsh::Transport::MacAlgorithm::None
  end

  it "appears as none in HrrRbSsh::Transport::MacAlgorithm.name_list" do
    expect( HrrRbSsh::Transport::MacAlgorithm.name_list ).to include 'none'
  end

  describe '#compute' do
    it "returns #{String.new.inspect}" do
      expect( mac_algorithm.compute transport, packet ).to eq String.new
    end
  end

  describe '#valid?' do
    context "when mac is #{String.new.inspect}" do
      let(:mac){ String.new }

      it "returns true" do
        expect( mac_algorithm.valid? transport, packet, mac ).to be true
      end
    end

    context "when mac is not #{String.new.inspect}" do
      let(:mac){ "dummy mac" }

      it "returns false" do
        expect( mac_algorithm.valid? transport, packet, mac ).to be false
      end
    end
  end

  describe '#length' do
    it "returns 0" do
      expect( mac_algorithm.length ).to eq 0
    end
  end
end
