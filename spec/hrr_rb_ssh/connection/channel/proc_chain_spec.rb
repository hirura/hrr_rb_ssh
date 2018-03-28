# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Connection::Channel::ProcChain do
  describe ".new" do
    it "takes no arguments" do
      expect { described_class.new }.not_to raise_error
    end

    it "cannot take any arguments" do
      expect { described_class.new 'dummy' }.to raise_error ArgumentError
    end
  end

  describe "#connect" do
    let(:proc_chain){ described_class.new }
    let(:q){ proc_chain.instance_variable_get('@q') }

    context "when next_proc is not nil" do
      let(:next_proc){ 'next proc' }

      it "enqueues next_proc" do
        expect(q.size).to eq 0
        proc_chain.connect next_proc
        expect(q.size).to eq 1
        proc_chain.connect next_proc
        expect(q.size).to eq 2
        expect(q.deq).to eq next_proc
        expect(q.size).to eq 1
        proc_chain.connect next_proc
        expect(q.size).to eq 2
        expect(q.deq).to eq next_proc
        expect(q.size).to eq 1
        expect(q.deq).to eq next_proc
        expect(q.size).to eq 0
      end
    end

    context "when next_proc is nil" do
      let(:next_proc){ nil }

      it "does not enqueue next_proc" do
        expect(q.size).to eq 0
        proc_chain.connect next_proc
        expect(q.size).to eq 0
      end
    end
  end

  describe "#call_next" do
    let(:proc_chain){ described_class.new }
    let(:q){ proc_chain.instance_variable_get('@q') }
    let(:next_proc){ double('next proc') }
    let(:chain_context_class){ HrrRbSsh::Connection::Channel::ProcChain::ChainContext }
    let(:arguments){ [1, 2, 3] }

    before :example do
      q.enq next_proc
    end

    it "calls dequeued next_proc.call with self and arguments" do
      expect(chain_context_class).to receive(:new).with(proc_chain).twice
      expect(next_proc).to receive(:call).with(chain_context_class.new(proc_chain), *arguments).once
      proc_chain.call_next *arguments
    end
  end
end
