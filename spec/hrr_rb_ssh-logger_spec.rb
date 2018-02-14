# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Logger do
  let(:name){ 'spec' }
  let(:l_mock){ double('logger') }
  let(:logger){ HrrRbSsh::Logger.new name }

  describe 'self#initialize' do
    it "takes one argument" do
      expect { HrrRbSsh::Logger.initialize l_mock }.not_to raise_error
    end

    it "initialize HrrRbSsh::Logger" do
      expect(HrrRbSsh::Logger.initialized?).to be_truthy
    end
  end

  describe 'self#uninitialize' do
    it "takes no arguments" do
      expect { HrrRbSsh::Logger.uninitialize }.not_to raise_error
    end

    it "uninitialize HrrRbSsh::Logger" do
      expect(HrrRbSsh::Logger.initialized?).to be_falsey
    end
  end

  describe 'self#initialized?' do
    it "is false when uninitialized" do
      HrrRbSsh::Logger.uninitialize
      expect(HrrRbSsh::Logger.initialized?).to be_falsey
    end

    it "is true when initialized" do
      HrrRbSsh::Logger.initialize l_mock
      expect(HrrRbSsh::Logger.initialized?).to be_truthy
    end
  end

  describe '#initialize' do
    it "takes one argument" do
      expect { HrrRbSsh::Logger.new name }.not_to raise_error
    end
  end

  describe '#fatal' do
    let(:method){ :fatal }

    context 'HrrRbSsh::Logger is not initialized' do
      before do
        HrrRbSsh::Logger.uninitialize
      end
      it "does not call #fatal method of @@logger" do
        expect { logger.send method, method }.not_to raise_error
      end
    end

    context 'HrrRbSsh::Logger is initialized' do
      before do
        HrrRbSsh::Logger.initialize l_mock
      end
      it "calls #fatal method of @@logger with '#\{name\}: ' prefix" do
        expect(l_mock).to receive(method).with("#{name}: #{method}").and_return("#{name}: #{method}").once
        expect(logger.send method, method).to eq "#{name}: #{method}"
      end
    end
  end

  describe '#error' do
    let(:method){ :error }

    context 'HrrRbSsh::Logger is not initialized' do
      before do
        HrrRbSsh::Logger.uninitialize
      end
      it "does not call #error method of @@logger" do
        expect { logger.send method, method }.not_to raise_error
      end
    end

    context 'HrrRbSsh::Logger is initialized' do
      before do
        HrrRbSsh::Logger.initialize l_mock
      end
      it "calls #error method of @@logger with '#\{name\}: ' prefix" do
        expect(l_mock).to receive(method).with("#{name}: #{method}").and_return("#{name}: #{method}").once
        expect(logger.send method, method).to eq "#{name}: #{method}"
      end
    end
  end

  describe '#warn' do
    let(:method){ :warn }

    context 'HrrRbSsh::Logger is not initialized' do
      before do
        HrrRbSsh::Logger.uninitialize
      end
      it "does not call #warn method of @@logger" do
        expect { logger.send method, method }.not_to raise_error
      end
    end

    context 'HrrRbSsh::Logger is initialized' do
      before do
        HrrRbSsh::Logger.initialize l_mock
      end
      it "calls #warn method of @@logger with '#\{name\}: ' prefix" do
        expect(l_mock).to receive(method).with("#{name}: #{method}").and_return("#{name}: #{method}").once
        expect(logger.send method, method).to eq "#{name}: #{method}"
      end
    end
  end

  describe '#info' do
    let(:method){ :info }

    context 'HrrRbSsh::Logger is not initialized' do
      before do
        HrrRbSsh::Logger.uninitialize
      end
      it "does not call #info method of @@logger" do
        expect { logger.send method, method }.not_to raise_error
      end
    end

    context 'HrrRbSsh::Logger is initialized' do
      before do
        HrrRbSsh::Logger.initialize l_mock
      end
      it "calls #info method of @@logger with '#\{name\}: ' prefix" do
        expect(l_mock).to receive(method).with("#{name}: #{method}").and_return("#{name}: #{method}").once
        expect(logger.send method, method).to eq "#{name}: #{method}"
      end
    end
  end

  describe '#debug' do
    let(:method){ :debug }

    context 'HrrRbSsh::Logger is not initialized' do
      before do
        HrrRbSsh::Logger.uninitialize
      end
      it "does not call #debug method of @@logger" do
        expect { logger.send method, method }.not_to raise_error
      end
    end

    context 'HrrRbSsh::Logger is initialized' do
      before do
        HrrRbSsh::Logger.initialize l_mock
      end
      it "calls #debug method of @@logger with '#\{name\}: ' prefix" do
        expect(l_mock).to receive(method).with("#{name}: #{method}").and_return("#{name}: #{method}").once
        expect(logger.send method, method).to eq "#{name}: #{method}"
      end
    end
  end
end
