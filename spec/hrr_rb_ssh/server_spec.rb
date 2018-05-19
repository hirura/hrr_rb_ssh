# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Server do
  describe '.new' do
    let(:io){ 'dummy' }
    let(:options){ Hash.new }

    it "must take at least one argument: io" do
      expect { described_class.new(io) }.not_to raise_error
    end

    it "can take two arguments: io and options" do
      expect { described_class.new(io, options) }.not_to raise_error
    end
  end

  describe '#start' do
    let(:io){ 'dummy' }
    let(:server){ described_class.new(io) }
    let(:connection){ double('connection') }

    before :example do
      server.instance_variable_set('@connection', connection)
    end

    it "calls @connection.start" do
      expect(connection).to receive(:start).with(no_args).once
      server.start
    end
  end
end
