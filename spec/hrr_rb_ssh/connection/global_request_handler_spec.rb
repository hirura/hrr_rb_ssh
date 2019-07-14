# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Connection::GlobalRequestHandler do
  let(:name){ 'forwarded-tcpip' }
  let(:io){ 'dummy' }
  let(:mode){ HrrRbSsh::Mode::SERVER }
  let(:transport){ HrrRbSsh::Transport.new io, mode }
  let(:authentication){ HrrRbSsh::Authentication.new transport, mode }
  let(:options){ Hash.new }
  let(:connection){ HrrRbSsh::Connection.new authentication, mode, options }
  let(:global_request_handler){ described_class.new connection }

  describe "#close" do
    it "exits, closes and clears any threads and servers" do
      global_request_handler.close
      expect(global_request_handler.instance_variable_get('@tcpip_forward_threads').empty?).to be true
      expect(global_request_handler.instance_variable_get('@tcpip_forward_servers').empty?).to be true
    end
  end

  describe "#request" do
    context "with \"tcpip-forward\"" do
      let(:message){
        {
          :'request name' => "tcpip-forward",
        }
      }
      it "calls tcpip_forward" do
        expect(global_request_handler).to receive(:tcpip_forward).with(message).once
        global_request_handler.request message
      end
    end

    context "with \"cancel-tcpip-forward\"" do
      let(:message){
        {
          :'request name' => "cancel-tcpip-forward",
        }
      }
      it "calls cancel_tcpip_forward" do
        expect(global_request_handler).to receive(:cancel_tcpip_forward).with(message).once
        global_request_handler.request message
      end
    end

    context "with \"other\" request name" do
      let(:message){
        {
          :'request name' => "other",
        }
      }
      it "raises error" do
        expect { global_request_handler.request message }.to raise_error RuntimeError
      end
    end
  end

  describe "#tcpip_forward" do
    let(:message){
      {
        :'request name' => "cancel-tcpip-forward",
        :'address to bind'     => "localhost",
        :'port number to bind' => 12345,
      }
    }

    after :example do
      global_request_handler.close
    end

    it "wakes up tcp server and starts a thread to accept tcp connections" do
      global_request_handler.tcpip_forward message
      expect(global_request_handler.instance_variable_get('@tcpip_forward_threads')["localhost:12345"].alive?).to be true
      expect(global_request_handler.instance_variable_get('@tcpip_forward_servers')["localhost:12345"].closed?).to be false
    end
  end

  describe "#cancel_tcpip_forward" do
    let(:message){
      {
        :'request name'        => "cancel-tcpip-forward",
        :'address to bind'     => "localhost",
        :'port number to bind' => 12345,
      }
    }
    let(:thread){ double('thread') }
    let(:server){ double('server') }

    before :example do
      global_request_handler.instance_variable_get('@tcpip_forward_threads')["localhost:12345"] = thread
      global_request_handler.instance_variable_get('@tcpip_forward_servers')["localhost:12345"] = server
    end

    it "exits, closes and deletes thread and server" do
      expect(thread).to receive(:exit).with(no_args).once
      expect(server).to receive(:close).with(no_args).once
      global_request_handler.cancel_tcpip_forward message
      expect(global_request_handler.instance_variable_get('@tcpip_forward_threads')["localhost:12345"]).to be nil
      expect(global_request_handler.instance_variable_get('@tcpip_forward_servers')["localhost:12345"]).to be nil
    end
  end
end
