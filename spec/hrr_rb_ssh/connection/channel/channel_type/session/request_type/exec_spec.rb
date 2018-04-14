# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Connection::Channel::ChannelType::Session::RequestType::Exec do
  let(:name){ 'exec' }

  it "can be looked up in HrrRbSsh::Connection::Channel::ChannelType::Session::RequestType dictionary" do
    expect( HrrRbSsh::Connection::Channel::ChannelType::Session::RequestType[name] ).to be described_class
  end

  describe ".run" do
    let(:proc_chain){ double("proc_chain") }
    let(:username){ 'username' }
    let(:io){ 'dummy' }
    let(:variables){ Hash.new }
    let(:message){ Hash.new }

    context "when options does not have 'connection_channel_request_exec'" do
      let(:options){ Hash.new }

      it "calls proc_chain.connect" do
        expect( proc_chain ).to receive(:connect).with(nil).once
        described_class.run proc_chain, username, io, variables, message, options
      end
    end

    context "when options has 'connection_channel_request_exec'" do
      let(:chain_proc){
        Proc.new {}
      }
      let(:options){
        {
          'connection_channel_request_exec' => HrrRbSsh::Connection::RequestHandler.new { |context|
            context.chain_proc &chain_proc
          }
        }
      }

      it "calls proc_chain.connect" do
        expect(proc_chain).to receive(:connect).with(chain_proc).once
        described_class.run proc_chain, username, io, variables, message, options
      end
    end
  end
end
