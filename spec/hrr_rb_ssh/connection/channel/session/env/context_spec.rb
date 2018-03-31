# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Connection::Channel::Session::Env::Context do
  let(:proc_chain){ "proc_chain" }
  let(:username){ "username" }
  let(:io){ 'dummy' }
  let(:variables){ Hash.new }
  let(:message){
    {
      HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::ID => HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::VALUE,
      'recipient channel'                            => 1,
      'request type'                                 => 'env',
      'want reply'                                   => true,
      'variable name'                                => 'variable name',
      'variable value'                               => 'variable value',
    }
  }
  let(:context){ described_class.new proc_chain, username, io, variables, message }

  describe ".new" do
    it "takes 5 arguments" do
      expect { context }.not_to raise_error
    end
  end

  describe "#chain_proc" do
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
    it "returns an instance of HrrRbSsh::Logger" do
      expect(context.logger).to be_an_instance_of HrrRbSsh::Logger
    end
  end

  describe "#io" do
    it "returns 'io' object" do
      expect(context.io).to be io
    end
  end

  describe "#variables" do
    it "returns 'variables' object" do
      expect(context.variables).to be variables
    end
  end

  describe "#vars" do
    it "returns 'variables' object" do
      expect(context.vars).to be variables
    end
  end

  describe "#variable_name" do
    it "returns message['variable name']" do
      expect(context.variable_name).to be message['variable name']
    end
  end

  describe "#variable_value" do
    it "returns message['variable value']" do
      expect(context.variable_value).to be message['variable value']
    end
  end
end
