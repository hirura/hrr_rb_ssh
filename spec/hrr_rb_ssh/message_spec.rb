# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Message do
  describe '.[]' do
    it "has hash defined" do
      expect { HrrRbSsh::Message['dummy'] }.not_to raise_error
    end
  end
end
