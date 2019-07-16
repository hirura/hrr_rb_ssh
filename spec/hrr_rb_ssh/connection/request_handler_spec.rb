# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Connection::RequestHandler do
  describe ".new" do
    it "takes block" do
      expect { ( described_class.new { |context| "block" } ) }.not_to raise_error
    end

    it "does not take arguments" do
      expect { ( described_class.new ("arg") { |context| "block" } ) }.to raise_error ArgumentError
    end
  end

  describe "#run" do
    let(:proc){ Proc.new do |context| context.to_s end }
    let(:request_handler){ described_class.new &proc }

    it "calls proc with context argument" do
      expect( request_handler.run 123 ).to eq "123"
    end
  end
end
