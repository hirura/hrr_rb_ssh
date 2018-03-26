# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Connection::Channel::Session::Shell::Context do
  let(:proc_chain){ "proc_chain" }
  let(:io){ 'dummy' }
  let(:variables){ Hash.new }
  let(:message){
    {
      HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::ID => HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::VALUE,
      'recipient channel'                            => 1,
      'request type'                                 => 'shell',
      'want reply'                                   => true,
    }
  }

  describe ".new" do
    it "takes 4 arguments" do
      expect { described_class.new proc_chain, io, variables, message }.not_to raise_error
    end
  end

  describe "#chain_proc" do
    let(:context){ described_class.new proc_chain, io, variables, message }

    context "with block" do
      let(:chain_proc){
        Proc.new {}
      }

      it "receives a block and returns a proc based on the block" do
        context.chain_proc &chain_proc
        expect(context.chain_proc).to be chain_proc
      end
    end

    context "with no block" do
      it "returns nil" do
        context.chain_proc
        expect(context.chain_proc).to be nil
      end
    end
  end

  describe "#logger" do
    let(:context){ described_class.new proc_chain, io, variables, message }

    it "returns an instance of HrrRbSsh::Logger" do
      expect(context.logger).to be_an_instance_of HrrRbSsh::Logger
    end
  end

  describe "#io" do
    let(:context){ described_class.new proc_chain, io, variables, message }

    it "returns 'io' object" do
      expect(context.io).to be io
    end
  end

  describe "#variables" do
    let(:context){ described_class.new proc_chain, io, variables, message }

    it "returns 'variables' object" do
      expect(context.variables).to be variables
    end
  end

  describe "#vars" do
    let(:context){ described_class.new proc_chain, io, variables, message }

    it "returns 'variables' object" do
      expect(context.vars).to be variables
    end
  end
end
