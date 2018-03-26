# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Connection::Channel::Session::Subsystem do
  it "is registered as \"subsystem\" in HrrRbSsh::Connection::Channel::Session.request_type_list" do
    expect( HrrRbSsh::Connection::Channel::Session['subsystem'] ).to eq described_class
  end

  it "appears as \"subsystem\" in HrrRbSsh::Connection::Channel::Session.request_type_list" do
    expect( HrrRbSsh::Connection::Channel::Session.request_type_list ).to include 'subsystem'
  end

  describe ".run" do
    let(:proc_chain){ double("proc_chain") }
    let(:io){ 'dummy' }
    let(:variables){ Hash.new }
    let(:message){ Hash.new }

    context "when options does not have 'connection_channel_request_subsystem'" do
      let(:options){ Hash.new }

      it "calls proc_chain.connect" do
        expect( proc_chain ).to receive(:connect).with(nil).once
        described_class.run proc_chain, io, variables, message, options
      end
    end

    context "when options has 'connection_channel_request_subsystem'" do
      let(:chain_proc){
        Proc.new {}
      }
      let(:options){
        {
          'connection_channel_request_subsystem' => HrrRbSsh::Connection::RequestHandler.new { |context|
            context.chain_proc &chain_proc
          }
        }
      }

      it "calls proc_chain.connect" do
        expect(proc_chain).to receive(:connect).with(chain_proc).once
        described_class.run proc_chain, io, variables, message, options
      end
    end
  end
end
