# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Authentication::Method::Publickey::Algorithm::SshEd25519 do
  let(:name){ 'ssh-ed25519' }
  let(:algorithm){ described_class.new }

  it "can be looked up in HrrRbSsh::Authentication::Method::Publickey::Algorithm dictionary" do
    expect( HrrRbSsh::Authentication::Method::Publickey::Algorithm[name] ).to eq described_class
  end

  it "is registered in HrrRbSsh::Authentication::Method::Publickey::Algorithm.list_supported" do
    expect( HrrRbSsh::Authentication::Method::Publickey::Algorithm.list_supported ).to include name
  end

  it "appears in HrrRbSsh::Authentication::Method::Publickey::Algorithm.list_preferred" do
    expect( HrrRbSsh::Authentication::Method::Publickey::Algorithm.list_preferred ).to include name
  end

  describe "::NAME" do
    it "is available" do
      expect( described_class::NAME ).to eq name
    end
  end

  describe '#verify_public_key' do
    let(:public_key_algorithm_name){ name }
    let(:public_key_str){
      <<-'EOB'
-----BEGIN PUBLIC KEY-----
MCowBQYDK2VwAyEA0xMv7hdAFjv2Q6aLOG9PP0dNXm9qkHGV7WewMgl1pcE=
-----END PUBLIC KEY-----
      EOB
    }
    let(:public_key){
      HrrRbSsh::Algorithm::Publickey::SshEd25519::PKey.new(public_key_str)
    }
    let(:public_key_blob){
      [
        HrrRbSsh::DataType::String.encode(public_key_algorithm_name),
        HrrRbSsh::DataType::String.encode(public_key.key_str),
      ].join
    }

    context "with correct arguments" do
      context "when public_key is an instance of String" do
        it "returns true" do
          expect(algorithm.verify_public_key public_key_algorithm_name, public_key_str, public_key_blob).to be true
        end
      end
    end

    context "with incorrect arguments" do
      context "when public_key_algorithm_name is incorrect" do
        let(:incorrect_public_key_algorithm_name){ 'incorrect' }

        it "returns false" do
          expect(algorithm.verify_public_key incorrect_public_key_algorithm_name, public_key_str, public_key_blob).to be false
        end
      end

      context "when public_key is not an instance of neither String nor OpenSSL::PKey::DSA" do
        let(:incorrect_public_key){ nil }

        it "returns false" do
          expect(algorithm.verify_public_key public_key_algorithm_name, incorrect_public_key, public_key_blob).to be false
        end
      end

      context "when public_key_blob is incorrect" do
        let(:incorrect_public_key_blob){ String.new }

        it "returns false" do
          expect(algorithm.verify_public_key public_key_algorithm_name, public_key_str, incorrect_public_key_blob).to be false
        end
      end
    end
  end

  describe '#verify_signature' do
    context 'with openssh private key' do
      let(:private_key_str){
        <<-'EOB'
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACCdRi5ulPa0Uy60B4hL9Z/RAFXb4EaeWw3j8Yqs8WFMUgAAAJBKCIFoSgiB
aAAAAAtzc2gtZWQyNTUxOQAAACCdRi5ulPa0Uy60B4hL9Z/RAFXb4EaeWw3j8Yqs8WFMUg
AAAECGaMyqiv+QFDjTBQu355SqjnhF0s4JVqoQ5F0cNbY3RZ1GLm6U9rRTLrQHiEv1n9EA
VdvgRp5bDePxiqzxYUxSAAAACmhycl9yYl9zc2gBAgM=
-----END OPENSSH PRIVATE KEY-----
        EOB
      }
      let(:pkey){ HrrRbSsh::Algorithm::Publickey::SshEd25519::PKey.new private_key_str }
      let(:public_key_blob){
        [
          HrrRbSsh::DataType::String.encode(name),
          HrrRbSsh::DataType::String.encode(pkey.public_key.key_str),
        ].join
      }
      let(:session_id){ "session id" }
      let(:username){ "username" }
      let(:message){
        {
          :'session identifier'        => session_id,
          :'message number'            => HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
          :'user name'                 => username,
          :'service name'              => "ssh-connection",
          :'method name'               => "publickey",
          :'with signature'            => true,
          :'public key algorithm name' => name,
          :'public key blob'           => public_key_blob,
          :'signature'                 => signature,
        }
      }
      let(:data){
        [
          HrrRbSsh::DataType::String.encode(session_id),
          HrrRbSsh::DataType::Byte.encode(HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE),
          HrrRbSsh::DataType::String.encode(username),
          HrrRbSsh::DataType::String.encode("ssh-connection"),
          HrrRbSsh::DataType::String.encode("publickey"),
          HrrRbSsh::DataType::Boolean.encode(true),
          HrrRbSsh::DataType::String.encode(name),
          HrrRbSsh::DataType::String.encode(public_key_blob),
        ].join
      }

      context "with correct signature" do
        let(:signature_blob){
          pkey.sign data
        }
        let(:signature){
          [
            HrrRbSsh::DataType::String.encode(name),
            HrrRbSsh::DataType::String.encode(signature_blob),
          ].join
        }

        it "returns true" do
          expect( algorithm.verify_signature(session_id, message) ).to be true
        end
      end

      context "with incorrect algorithm name" do
        let(:signature_blob){
          pkey.sign data
        }
        let(:signature){
          [
            HrrRbSsh::DataType::String.encode("incorrect"),
            HrrRbSsh::DataType::String.encode(signature_blob),
          ].join
        }

        it "returns false" do
          expect( algorithm.verify_signature(session_id, message) ).to be false
        end
      end

      context "with incorrect signature" do
        let(:signature_blob){
          pkey.sign data
        }
        let(:incorrect_signature_blob){ "incorrect" + signature_blob }
        let(:signature){
          [
            HrrRbSsh::DataType::String.encode(name),
            HrrRbSsh::DataType::String.encode(incorrect_signature_blob),
          ].join
        }

        it "returns false" do
          expect( algorithm.verify_signature(session_id, message) ).to be false
        end
      end
    end

    context 'with openssl private key' do
      let(:private_key_str){
        <<-'EOB'
-----BEGIN PRIVATE KEY-----
MC4CAQAwBQYDK2VwBCIEIO8BvFjQCQGGsNbq0c7uh81pvpNhun6uAPTz3lb/cXHA
-----END PRIVATE KEY-----
        EOB
      }
      let(:pkey){ HrrRbSsh::Algorithm::Publickey::SshEd25519::PKey.new private_key_str }
      let(:public_key_blob){
        [
          HrrRbSsh::DataType::String.encode(name),
          HrrRbSsh::DataType::String.encode(pkey.public_key.key_str),
        ].join
      }
      let(:session_id){ "session id" }
      let(:username){ "username" }
      let(:message){
        {
          :'session identifier'        => session_id,
          :'message number'            => HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
          :'user name'                 => username,
          :'service name'              => "ssh-connection",
          :'method name'               => "publickey",
          :'with signature'            => true,
          :'public key algorithm name' => name,
          :'public key blob'           => public_key_blob,
          :'signature'                 => signature,
        }
      }
      let(:data){
        [
          HrrRbSsh::DataType::String.encode(session_id),
          HrrRbSsh::DataType::Byte.encode(HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE),
          HrrRbSsh::DataType::String.encode(username),
          HrrRbSsh::DataType::String.encode("ssh-connection"),
          HrrRbSsh::DataType::String.encode("publickey"),
          HrrRbSsh::DataType::Boolean.encode(true),
          HrrRbSsh::DataType::String.encode(name),
          HrrRbSsh::DataType::String.encode(public_key_blob),
        ].join
      }

      context "with correct signature" do
        let(:signature_blob){
          pkey.sign data
        }
        let(:signature){
          [
            HrrRbSsh::DataType::String.encode(name),
            HrrRbSsh::DataType::String.encode(signature_blob),
          ].join
        }

        it "returns true" do
          expect( algorithm.verify_signature(session_id, message) ).to be true
        end
      end

      context "with incorrect algorithm name" do
        let(:signature_blob){
          pkey.sign data
        }
        let(:signature){
          [
            HrrRbSsh::DataType::String.encode("incorrect"),
            HrrRbSsh::DataType::String.encode(signature_blob),
          ].join
        }

        it "returns false" do
          expect( algorithm.verify_signature(session_id, message) ).to be false
        end
      end

      context "with incorrect signature" do
        let(:signature_blob){
          pkey.sign data
        }
        let(:incorrect_signature_blob){ "incorrect" + signature_blob }
        let(:signature){
          [
            HrrRbSsh::DataType::String.encode(name),
            HrrRbSsh::DataType::String.encode(incorrect_signature_blob),
          ].join
        }

        it "returns false" do
          expect( algorithm.verify_signature(session_id, message) ).to be false
        end
      end
    end
  end
end
