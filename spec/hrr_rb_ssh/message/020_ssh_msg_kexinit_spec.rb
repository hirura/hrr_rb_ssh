# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Message::SSH_MSG_KEXINIT do
  let(:id){ 'SSH_MSG_KEXINIT' }
  let(:value){ 20 }
  let(:num_fields){ 29 }

  describe "::ID" do
    it "is defined" do
      expect(described_class::ID).to eq id
    end
  end

  describe "::VALUE" do
    it "is defined" do
      expect(described_class::VALUE).to eq value
    end
  end

  describe ".definition" do
    it "is defined" do
      expect(described_class.definition.size).to eq num_fields
    end
  end
end