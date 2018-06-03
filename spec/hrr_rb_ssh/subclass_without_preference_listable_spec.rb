# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::SubclassWithoutPreferenceListable do
  let(:superclass){
    Class.new do
      @subclass_list = Array.new
      class << self
        include HrrRbSsh::SubclassWithoutPreferenceListable
      end
    end
  }

  let(:subclass0){
    Class.new(superclass) do
      const_set(:NAME, 'subclass0')
    end
  }
  let(:subclass1){
    Class.new(superclass) do
      const_set(:NAME, 'subclass1')
    end
  }
  let(:subclass2){
    Class.new(superclass) do
      const_set(:NAME, 'subclass2')
    end
  }

  context "superclass" do
    describe ".inherited" do
      it "can be inherited" do
        expect { subclass0 }.not_to raise_error
      end
    end

    describe "[key]" do
      context "when superclass does not have subclasses" do
        it "returns nil" do
          expect(superclass['key']).to be nil
        end
      end

      context "when superclass has subclasses" do
        before :example do
          subclass0
          subclass1
          subclass2
        end

        it "returns a class that has a name specified as the key" do
          expect(superclass['subclass0']).to be subclass0
          expect(superclass['subclass1']).to be subclass1
          expect(superclass['subclass2']).to be subclass2
        end
      end
    end

    describe ".list_supported" do
      context "when superclass does not have subclasses" do
        it "returns []" do
          expect(superclass.list_supported).to eq []
        end
      end

      context "when superclass has subclasses" do
        before :example do
          subclass0
          subclass1
          subclass2
        end

        it "returns an instance of Array that containes subclasses' name" do
          expect(superclass.list_supported).to include 'subclass0', 'subclass1', 'subclass2'
        end
      end
    end
  end

  context "subclass" do
    describe ".inherited" do
      it "can be inherited" do
        expect { Class.new(subclass0) }.not_to raise_error
      end
    end

    describe "[key]" do
      it "raises NoMethodError" do
        expect { subclass0['key'] }.to raise_error NoMethodError
      end
    end

    describe ".list_supported" do
      it "raises NoMethodError" do
        expect { subclass0.list_supported }.to raise_error NoMethodError
      end
    end
  end
end
