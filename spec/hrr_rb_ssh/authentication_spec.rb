# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Authentication do
  describe '::SERVICE_NAME' do
    let(:service_name){ 'ssh-userauth' }

    it "is defined" do
      expect( described_class::SERVICE_NAME ).to eq service_name
    end
  end

  describe '#new' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }

    it "takes one argument: transport" do
      expect { described_class.new(transport) }.not_to raise_error
    end

    it "registeres ::SERVICE_NAME in transport" do
      expect {
        described_class.new transport
      }.to change {
        transport.instance_variable_get(:@acceptable_services)
      }.from([]).to([described_class::SERVICE_NAME])
    end
  end

  describe '#start' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ described_class.new(transport) }

    it "calls transport.start" do
      expect( transport ).to receive(:start).with(no_args).once

      authentication.start
    end
  end
end
