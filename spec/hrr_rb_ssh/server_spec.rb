# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Server do
  describe '.start' do
    let(:io){ 'dummy' }
    let(:options){ Hash.new }
    let(:transport){ double('transport') }
    let(:authentication){ double('authentication') }
    let(:connection){ double('connection') }

    it "must take at least one argument: io" do
      expect(HrrRbSsh::Transport).to receive(:new).with(io, HrrRbSsh::Mode::SERVER, {}).and_return(transport)
      expect(HrrRbSsh::Authentication).to receive(:new).with(transport, {}).and_return(authentication)
      expect(HrrRbSsh::Connection).to receive(:new).with(authentication, {}).and_return(connection)
      expect(connection).to receive(:start).with(no_args).once
      expect { described_class.start(io) }.not_to raise_error
    end

    it "can take two arguments: io and options" do
      expect(HrrRbSsh::Transport).to receive(:new).with(io, HrrRbSsh::Mode::SERVER, options).and_return(transport)
      expect(HrrRbSsh::Authentication).to receive(:new).with(transport, options).and_return(authentication)
      expect(HrrRbSsh::Connection).to receive(:new).with(authentication, options).and_return(connection)
      expect(connection).to receive(:start).with(no_args).once
      expect { described_class.start(io, options) }.not_to raise_error
    end
  end

  describe '.new' do
    let(:options){ Hash.new }

    it "doesn't need to take arguments" do
      expect { described_class.new }.not_to raise_error
    end

    it "can take an arguments: options" do
      expect { described_class.new(options) }.not_to raise_error
    end
  end

  describe '#start' do
    let(:io){ 'dummy' }
    let(:server){ described_class.new }
    let(:transport){ double('transport') }
    let(:authentication){ double('authentication') }
    let(:connection){ double('connection') }

    it "calls connection.start" do
      expect(HrrRbSsh::Transport).to receive(:new).with(io, HrrRbSsh::Mode::SERVER, {}).and_return(transport)
      expect(HrrRbSsh::Authentication).to receive(:new).with(transport, {}).and_return(authentication)
      expect(HrrRbSsh::Connection).to receive(:new).with(authentication, {}).and_return(connection)
      expect(connection).to receive(:start).with(no_args).once
      expect { server.start io }.not_to raise_error
    end
  end
end
