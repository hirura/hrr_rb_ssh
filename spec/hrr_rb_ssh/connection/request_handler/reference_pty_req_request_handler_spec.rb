# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Connection::RequestHandler::ReferencePtyReqRequestHandler do
  describe ".new" do
    it "does not take any arguments" do
      expect { described_class.new("arg") }.to raise_error ArgumentError
    end
  end

  describe "#run" do
    let(:request_handler){ described_class.new }

    let(:context){
      HrrRbSsh::Connection::Channel::ChannelType::Session::RequestType::PtyReq::Context.new proc_chain, username, io, variables, message, session
    }

    let(:proc_chain){
      double('proc_chain')
    }
    let(:username){
      ENV['USER']
    }
    let(:io){
      double('io')
    }
    let(:variables){
      {}
    }
    let(:message){
      {
         :'TERM environment variable value' => 'dummy TERM env var value',
         :'terminal width, characters'      => 200,
         :'terminal height, rows'           => 100,
         :'terminal width, pixels'          => 2000,
         :'terminal height, pixels'         => 1000,
         :'encoded terminal modes'          => 'dummy encoded term modes',
      }
    }
    let(:session){
      double('session')
    }

    let(:chain){
      double('chain')
    }

    let(:io_in_r){ double('io_in_r') }
    let(:io_out_w){ double('io_out_w') }
    let(:io_err_w){ double('io_err_w') }

    context "with no error in Proc.new" do
      context "with no error in chain_proc" do
        it "calls proc with context argument" do
          allow(io).to receive(:[]).with(0).and_return(io_in_r)
          allow(io).to receive(:[]).with(1).and_return(io_out_w)
          allow(io).to receive(:[]).with(2).and_return(io_err_w)
          allow(io_in_r).to receive(:readpartial).with(any_args)
          allow(io_out_w).to receive(:write).with(any_args)
          allow(io_err_w).to receive(:write).with(any_args)

          expect { request_handler.run context }.not_to raise_error
          expect(chain).to receive(:call_next).and_return(0).once
          expect(context.chain_proc.call chain).to eq 0
          expect(variables[:env]['TERM']).to eq message[:'TERM environment variable value']
          expect(variables[:ptm].closed?).to be true
          expect(variables[:pts].closed?).to be true
        end
      end

      context "with error in chain_proc" do
        context "with EOFError error in ptm_read_thread" do
          it "calls proc with context argument" do
            allow(io).to receive(:[]).with(0).and_return(io_in_r)
            allow(io).to receive(:[]).with(1).and_return(io_out_w)
            allow(io).to receive(:[]).with(2).and_return(io_err_w)
            allow(io_in_r).to receive(:readpartial).with(any_args)
            allow(io_out_w).to receive(:write).with(any_args)
            allow(io_err_w).to receive(:write).with(any_args)

            expect { request_handler.run context }.not_to raise_error
            expect(variables[:ptm]).to receive(:readpartial).with(any_args).and_raise(EOFError)
            expect(chain).to receive(:call_next).and_return(0).once
            expect(context.chain_proc.call chain).to eq 0
            expect(variables[:env]['TERM']).to eq message[:'TERM environment variable value']
            expect(variables[:ptm].closed?).to be true
            expect(variables[:pts].closed?).to be true
          end
        end

        context "with IOError error in ptm_read_thread" do
          it "calls proc with context argument" do
            allow(io).to receive(:[]).with(0).and_return(io_in_r)
            allow(io).to receive(:[]).with(1).and_return(io_out_w)
            allow(io).to receive(:[]).with(2).and_return(io_err_w)
            allow(io_in_r).to receive(:readpartial).with(any_args)
            allow(io_out_w).to receive(:write).with(any_args)
            allow(io_err_w).to receive(:write).with(any_args)

            expect { request_handler.run context }.not_to raise_error
            expect(variables[:ptm]).to receive(:readpartial).with(any_args).and_raise(IOError)
            expect(chain).to receive(:call_next).and_return(0).once
            expect(context.chain_proc.call chain).to eq 0
            expect(variables[:env]['TERM']).to eq message[:'TERM environment variable value']
            expect(variables[:ptm].closed?).to be true
            expect(variables[:pts].closed?).to be true
          end
        end

        context "with Errno::EIO error in ptm_read_thread" do
          it "calls proc with context argument" do
            allow(io).to receive(:[]).with(0).and_return(io_in_r)
            allow(io).to receive(:[]).with(1).and_return(io_out_w)
            allow(io).to receive(:[]).with(2).and_return(io_err_w)
            allow(io_in_r).to receive(:readpartial).with(any_args)
            allow(io_out_w).to receive(:write).with(any_args)
            allow(io_err_w).to receive(:write).with(any_args)

            expect { request_handler.run context }.not_to raise_error
            expect(variables[:ptm]).to receive(:readpartial).with(any_args).and_raise(Errno::EIO)
            expect(chain).to receive(:call_next).and_return(0).once
            expect(context.chain_proc.call chain).to eq 0
            expect(variables[:env]['TERM']).to eq message[:'TERM environment variable value']
            expect(variables[:ptm].closed?).to be true
            expect(variables[:pts].closed?).to be true
          end
        end

        context "with RuntimeError error in ptm_read_thread" do
          it "calls proc with context argument" do
            allow(io).to receive(:[]).with(0).and_return(io_in_r)
            allow(io).to receive(:[]).with(1).and_return(io_out_w)
            allow(io).to receive(:[]).with(2).and_return(io_err_w)
            allow(io_in_r).to receive(:readpartial).with(any_args)
            allow(io_out_w).to receive(:write).with(any_args)
            allow(io_err_w).to receive(:write).with(any_args)

            expect { request_handler.run context }.not_to raise_error
            expect(variables[:ptm]).to receive(:readpartial).with(any_args).and_raise(RuntimeError)
            expect(chain).to receive(:call_next).and_return(0).once
            expect(context.chain_proc.call chain).to eq 0
            expect(variables[:env]['TERM']).to eq message[:'TERM environment variable value']
            expect(variables[:ptm].closed?).to be true
            expect(variables[:pts].closed?).to be true
          end
        end

        context "with EOFError error in ptm_write_thread" do
          it "calls proc with context argument" do
            allow(io).to receive(:[]).with(0).and_return(io_in_r)
            allow(io).to receive(:[]).with(1).and_return(io_out_w)
            allow(io).to receive(:[]).with(2).and_return(io_err_w)
            allow(io_in_r).to receive(:readpartial).with(any_args).and_raise(EOFError)
            allow(io_out_w).to receive(:write).with(any_args)
            allow(io_err_w).to receive(:write).with(any_args)

            expect { request_handler.run context }.not_to raise_error
            expect(chain).to receive(:call_next).and_return(0).once
            expect(context.chain_proc.call chain).to eq 0
            expect(variables[:env]['TERM']).to eq message[:'TERM environment variable value']
            expect(variables[:ptm].closed?).to be true
            expect(variables[:pts].closed?).to be true
          end
        end

        context "with IOError error in ptm_write_thread" do
          it "calls proc with context argument" do
            allow(io).to receive(:[]).with(0).and_return(io_in_r)
            allow(io).to receive(:[]).with(1).and_return(io_out_w)
            allow(io).to receive(:[]).with(2).and_return(io_err_w)
            allow(io_in_r).to receive(:readpartial).with(any_args).and_raise(IOError)
            allow(io_out_w).to receive(:write).with(any_args)
            allow(io_err_w).to receive(:write).with(any_args)

            expect { request_handler.run context }.not_to raise_error
            expect(chain).to receive(:call_next).and_return(0).once
            expect(context.chain_proc.call chain).to eq 0
            expect(variables[:env]['TERM']).to eq message[:'TERM environment variable value']
            expect(variables[:ptm].closed?).to be true
            expect(variables[:pts].closed?).to be true
          end
        end

        context "with Errno::EIO error in ptm_write_thread" do
          it "calls proc with context argument" do
            allow(io).to receive(:[]).with(0).and_return(io_in_r)
            allow(io).to receive(:[]).with(1).and_return(io_out_w)
            allow(io).to receive(:[]).with(2).and_return(io_err_w)
            allow(io_in_r).to receive(:readpartial).with(any_args).and_raise(Errno::EIO)
            allow(io_out_w).to receive(:write).with(any_args)
            allow(io_err_w).to receive(:write).with(any_args)

            expect { request_handler.run context }.not_to raise_error
            expect(chain).to receive(:call_next).and_return(0).once
            expect(context.chain_proc.call chain).to eq 0
            expect(variables[:env]['TERM']).to eq message[:'TERM environment variable value']
            expect(variables[:ptm].closed?).to be true
            expect(variables[:pts].closed?).to be true
          end
        end

        context "with RuntimeError error in ptm_write_thread" do
          it "calls proc with context argument" do
            allow(io).to receive(:[]).with(0).and_return(io_in_r)
            allow(io).to receive(:[]).with(1).and_return(io_out_w)
            allow(io).to receive(:[]).with(2).and_return(io_err_w)
            allow(io_in_r).to receive(:readpartial).with(any_args).and_raise(RuntimeError)
            allow(io_out_w).to receive(:write).with(any_args)
            allow(io_err_w).to receive(:write).with(any_args)

            expect { request_handler.run context }.not_to raise_error
            expect(chain).to receive(:call_next).and_return(0).once
            expect(context.chain_proc.call chain).to eq 0
            expect(variables[:env]['TERM']).to eq message[:'TERM environment variable value']
            expect(variables[:ptm].closed?).to be true
            expect(variables[:pts].closed?).to be true
          end
        end
      end
    end

    context "with error in Proc.new" do
      it "closes ptm and pts, makes chain_proc return exitstatus 1, and raises error" do
        expect(context).to receive(:term_environment_variable_value).and_raise(RuntimeError)
        expect { request_handler.run context }.to raise_error RuntimeError
        expect(variables[:ptm].closed?).to be true
        expect(variables[:pts].closed?).to be true
        expect(context.chain_proc.call chain).to eq 1
      end
    end
  end
end
