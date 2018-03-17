# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Authentication::Method do
  describe '.[]' do
    context "when arg is unregistered" do
      it "returns nil" do
        expect( HrrRbSsh::Authentication::Method['unregistered'] ).to be nil
      end
    end
  end

  describe '.name_list' do
    it "returns an instance of Array" do
      expect( HrrRbSsh::Authentication::Method.name_list ).to be_an_instance_of Array
    end
  end
end
