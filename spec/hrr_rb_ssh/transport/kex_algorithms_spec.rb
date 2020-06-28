RSpec.describe HrrRbSsh::Transport::KexAlgorithms do
  dummy_class_name = :"Dummy"
  dummy_name = "dummy"
  dummy_preference = 100

  let(:kex_algorithms){ described_class.new }

  before :all do
    @dummy_class = Class.new do |klass|
      klass::NAME = dummy_name
      klass::PREFERENCE = dummy_preference
      def initialize logger: nil
      end
    end
    described_class.send(:const_set, dummy_class_name, @dummy_class)
  end

  after :all do
    described_class.send(:remove_const, dummy_class_name)
  end

  describe '#list_supported' do
    it "returns an Array that includes class names" do
      expect( kex_algorithms.list_supported ).to include (dummy_name)
    end
  end

  describe '#list_preferred' do
    it "returns an Array that includes class names with preference" do
      expect( kex_algorithms.list_preferred ).to include (dummy_name)
    end
  end

  describe '#instantiate' do
    it "returns an instance of dummy class" do
      expect( kex_algorithms.instantiate(dummy_name) ).to be_an_instance_of @dummy_class
    end
  end
end
