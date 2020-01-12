# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Loggable do
  context "when initialize method does not initialize internal logger" do
    let(:loggable_instance){
      Class.new{
        include HrrRbSsh::Loggable
      }.new
    }

    describe ".initialize" do
      it "does not initialize @logger" do
        expect(loggable_instance.instance_variable_get("@logger")).to be nil
      end
    end

    describe "#logger" do
      it "returns nil" do
        expect(loggable_instance.logger).to be nil
      end
    end

    describe "#log_key" do
      context "when log_key is not specified" do
        it "returns class name with hex object id" do
          expect(loggable_instance.log_key).to eq (loggable_instance.class.to_s + "[%x]" % loggable_instance.object_id)
        end
      end

      context "when log_key is specified" do
        let(:log_key){ "log_key" }

        before :example do
          loggable_instance.log_key = log_key
        end

        it "returns specified log_key" do
          expect(loggable_instance.log_key).to be log_key
        end
      end
    end
  end

  context "when initialize method initializes internal logger" do
    let(:internal_logger){
      Class.new{
        def fatal arg; arg + yield; end
        def error arg; arg + yield; end
        def warn  arg; arg + yield; end
        def info  arg; arg + yield; end
        def debug arg; arg + yield; end
      }.new
    }

    let(:loggable_instance){
      Class.new{
        include HrrRbSsh::Loggable
        def initialize logger
          self.logger = logger
        end
      }.new(internal_logger)
    }

    describe ".initialize" do
      it "initializes @logger" do
        expect(loggable_instance.instance_variable_get("@logger")).to be internal_logger
      end
    end

    describe "#logger" do
      it "returns logger" do
        expect(loggable_instance.logger).to be internal_logger
      end
    end

    describe "#log_key" do
      context "when log_key is not specified" do
        it "returns class name with hex object id" do
          expect(loggable_instance.log_key).to eq (loggable_instance.class.to_s + "[%x]" % loggable_instance.object_id)
        end
      end

      context "when log_key is specified" do
        let(:log_key){ "log_key" }

        before :example do
          loggable_instance.log_key = log_key
        end

        it "returns specified log_key" do
          expect(loggable_instance.log_key).to be log_key
        end
      end
    end

    describe '#log_fatal' do
      let(:log_key){ "log_key" }
      let(:msg){ "msg" }

      before :example do
        loggable_instance.log_key = log_key
      end

      it "calls #fatal method of internal logger with log_key progname and message block" do
        expect(loggable_instance.log_fatal { msg }).to eq (log_key + msg)
      end
    end

    describe '#log_error' do
      let(:log_key){ "log_key" }
      let(:msg){ "msg" }

      before :example do
        loggable_instance.log_key = log_key
      end

      it "calls #error method of internal logger with log_key progname and message block" do
        expect(loggable_instance.log_error { msg }).to eq (log_key + msg)
      end
    end

    describe '#log_warn' do
      let(:log_key){ "log_key" }
      let(:msg){ "msg" }

      before :example do
        loggable_instance.log_key = log_key
      end

      it "calls #warn method of internal logger with log_key progname and message block" do
        expect(loggable_instance.log_warn { msg }).to eq (log_key + msg)
      end
    end

    describe '#log_info' do
      let(:log_key){ "log_key" }
      let(:msg){ "msg" }

      before :example do
        loggable_instance.log_key = log_key
      end

      it "calls #info method of internal logger with log_key progname and message block" do
        expect(loggable_instance.log_info { msg }).to eq (log_key + msg)
      end
    end

    describe '#log_debug' do
      let(:log_key){ "log_key" }
      let(:msg){ "msg" }

      before :example do
        loggable_instance.log_key = log_key
      end

      it "calls #debug method of internal logger with log_key progname and message block" do
        expect(loggable_instance.log_debug { msg }).to eq (log_key + msg)
      end
    end
  end
end
