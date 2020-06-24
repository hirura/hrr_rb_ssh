RSpec.describe HrrRbSsh::Connection::RequestHandler::ReferenceWindowChangeRequestHandler do
  describe ".new" do
    it "does not take any arguments" do
      expect { described_class.new("arg") }.to raise_error ArgumentError
    end
  end

  describe "#run" do
    let(:request_handler){ described_class.new }

    let(:context){
      HrrRbSsh::Connection::Channel::ChannelType::Session::RequestType::WindowChange::Context.new proc_chain, username, io, variables, message, session
    }

    let(:proc_chain){
      double('proc_chain')
    }
    let(:username){
      double('username')
    }
    let(:io){
      double('io')
    }
    let(:variables){
      {
        :ptm => ptm,
      }
    }
    let(:message){
      {
        :'terminal width, columns' => 200,
        :'terminal height, rows'   => 100,
        :'terminal width, pixels'  => 2000,
        :'terminal height, pixels' => 1000,
      }
    }
    let(:session){
      double('session')
    }

    let(:ptm_pts){ PTY.open }
    let(:ptm){ ptm_pts[0] }
    let(:pts){ ptm_pts[1] }

    after :example do
      ptm.close rescue nil
      pts.close rescue nil
    end

    it "calls proc with context argument" do
      request_handler.run context
      expect( ptm.winsize ).to eq [100, 200]
    end
  end
end
