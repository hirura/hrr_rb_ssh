RSpec.describe HrrRbSsh::Connection::Channel::ChannelType::Session::ProcChain::ChainContext do
  describe ".new" do
    let(:proc_chain){ double("proc_chain") }

    it "takes 1 argument" do
      expect { described_class.new proc_chain }.not_to raise_error
    end
  end

  describe "#call_next" do
    let(:proc_chain){ double("proc_chain") }
    let(:chain_context){ described_class.new proc_chain }

    context "with no arguments" do
      let(:args){ [] }

      it "calls proc_chain.call_next with no arguments" do
        expect(proc_chain).to receive(:call_next).with(no_args).once
        chain_context.call_next *args
      end
    end

    context "with 1 argument" do
      let(:args){ [1] }

      it "calls proc_chain.call_next with 1 argument" do
        expect(proc_chain).to receive(:call_next).with(*args).once
        chain_context.call_next *args
      end
    end

    context "with multiple arguments" do
      let(:args){ [1, 2, 3] }

      it "calls proc_chain.call_next with multiple arguments" do
        expect(proc_chain).to receive(:call_next).with(*args).once
        chain_context.call_next *args
      end
    end
  end
end
