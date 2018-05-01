# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Logger do
  let(:name){ 'spec' }
  let(:internal_logger){
    Class.new{
      def fatal; yield; end
      def error; yield; end
      def warn;  yield; end
      def info;  yield; end
      def debug; yield; end
    }.new
  }
  let(:logger){ described_class.new name }

  describe '.initialize' do
    it "takes one argument" do
      expect { HrrRbSsh::Logger.initialize internal_logger }.not_to raise_error
    end

    it "initialize HrrRbSsh::Logger" do
      HrrRbSsh::Logger.initialize internal_logger
      expect(HrrRbSsh::Logger.initialized?).to be true
    end
  end

  describe '.uninitialize' do
    it "takes no arguments" do
      expect { HrrRbSsh::Logger.uninitialize }.not_to raise_error
    end

    it "uninitialize HrrRbSsh::Logger" do
      HrrRbSsh::Logger.initialize internal_logger
      HrrRbSsh::Logger.uninitialize
      expect(HrrRbSsh::Logger.initialized?).to be false
    end
  end

  describe '.initialized?' do
    it "is false when uninitialized" do
      HrrRbSsh::Logger.initialize internal_logger
      HrrRbSsh::Logger.uninitialize
      expect(HrrRbSsh::Logger.initialized?).to be false
    end

    it "is true when initialized" do
      HrrRbSsh::Logger.initialize internal_logger
      expect(HrrRbSsh::Logger.initialized?).to be true
    end
  end

  describe '#new' do
    it "takes one argument" do
      expect { HrrRbSsh::Logger.new name }.not_to raise_error
    end
  end

  describe '#fatal' do
    let(:method){ :fatal }

    context 'HrrRbSsh::Logger is not initialized' do
      before :example do
        HrrRbSsh::Logger.uninitialize
      end
      it "does not call #fatal method of @@logger" do
        expect { logger.send(method){ method } }.not_to raise_error
      end
    end

    context 'HrrRbSsh::Logger is initialized' do
      before :example do
        HrrRbSsh::Logger.initialize internal_logger
      end
      it "calls #fatal method of @@logger with '#\{name\}: ' prefix" do
        expect(logger.send(method){ method }).to eq "#{name}: #{method}"
      end
    end
  end

  describe '#error' do
    let(:method){ :error }

    context 'HrrRbSsh::Logger is not initialized' do
      before :example do
        HrrRbSsh::Logger.uninitialize
      end
      it "does not call #error method of @@logger" do
        expect { logger.send(method){ method } }.not_to raise_error
      end
    end

    context 'HrrRbSsh::Logger is initialized' do
      before :example do
        HrrRbSsh::Logger.initialize internal_logger
      end
      it "calls #error method of @@logger with '#\{name\}: ' prefix" do
        expect(logger.send(method){ method }).to eq "#{name}: #{method}"
      end
    end
  end

  describe '#warn' do
    let(:method){ :warn }

    context 'HrrRbSsh::Logger is not initialized' do
      before :example do
        HrrRbSsh::Logger.uninitialize
      end
      it "does not call #warn method of @@logger" do
        expect { logger.send(method){ method } }.not_to raise_error
      end
    end

    context 'HrrRbSsh::Logger is initialized' do
      before :example do
        HrrRbSsh::Logger.initialize internal_logger
      end
      it "calls #warn method of @@logger with '#\{name\}: ' prefix" do
        expect(logger.send(method){ method }).to eq "#{name}: #{method}"
      end
    end
  end

  describe '#info' do
    let(:method){ :info }

    context 'HrrRbSsh::Logger is not initialized' do
      before :example do
        HrrRbSsh::Logger.uninitialize
      end
      it "does not call #info method of @@logger" do
        expect { logger.send(method){ method } }.not_to raise_error
      end
    end

    context 'HrrRbSsh::Logger is initialized' do
      before :example do
        HrrRbSsh::Logger.initialize internal_logger
      end
      it "calls #info method of @@logger with '#\{name\}: ' prefix" do
        expect(logger.send(method){ method }).to eq "#{name}: #{method}"
      end
    end
  end

  describe '#debug' do
    let(:method){ :debug }

    context 'HrrRbSsh::Logger is not initialized' do
      before :example do
        HrrRbSsh::Logger.uninitialize
      end
      it "does not call #debug method of @@logger" do
        expect { logger.send(method){ method } }.not_to raise_error
      end
    end

    context 'HrrRbSsh::Logger is initialized' do
      before :example do
        HrrRbSsh::Logger.initialize internal_logger
      end
      it "calls #debug method of @@logger with '#\{name\}: ' prefix" do
        expect(logger.send(method){ method }).to eq "#{name}: #{method}"
      end
    end
  end
end
