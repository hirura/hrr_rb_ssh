# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Connection::RequestHandler::ReferenceEnvRequestHandler do
  describe ".new" do
    it "does not take any arguments" do
      expect { described_class.new("arg") }.to raise_error ArgumentError
    end
  end

  describe "#run" do
    let(:request_handler){ described_class.new }

    let(:context){
      HrrRbSsh::Connection::Channel::ChannelType::Session::RequestType::Env::Context.new proc_chain, username, io, variables, message, session
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
      {}
    }
    let(:message){
      {
        :'variable name'  => variable_name,
        :'variable value' => variable_value,
      }
    }
    let(:session){
      double('session')
    }

    let(:variable_name ){ 'variable name'  }
    let(:variable_value){ 'variable value' }

    it "calls proc with context argument" do
      request_handler.run context
      expect(variables[:env]).to eq ({variable_name => variable_value})
    end
  end
end
