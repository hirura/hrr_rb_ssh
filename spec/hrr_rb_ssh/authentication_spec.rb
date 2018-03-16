# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Authentication do
  describe '#new' do
    let(:transport){ double("transport") }

    it "takes one argument: transport" do
      expect { described_class.new(transport) }.not_to raise_error
    end
  end
end
