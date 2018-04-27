# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Authentication::Method::Publickey::Algorithm::EcdsaSha2Nistp521 do
  let(:name){ 'ecdsa-sha2-nistp521' }
  let(:digest){ 'sha512' }
  let(:identifier){ 'nistp521' }
  let(:curve_name){ 'secp521r1' }
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

  describe "::DIGEST" do
    it "is available" do
      expect( described_class::DIGEST ).to eq digest
    end
  end

  describe "::IDENTIFIER" do
    it "is available" do
      expect( described_class::IDENTIFIER ).to eq identifier
    end
  end

  describe "::CURVE_NAME" do
    it "is available" do
      expect( described_class::CURVE_NAME ).to eq curve_name
    end
  end

  describe '#verify_public_key' do
    let(:public_key_algorithm_name){ name }
    let(:public_key_str){
      <<-'EOB'
-----BEGIN PUBLIC KEY-----
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAWpyjYdvgk1+k5029Xvy9JRKRPbm8
vjJ3OCO5ctJkBo8EJz9mrg943yDS7PzibowO8ArnkzVLbKrhhXfRK2tpouYA+CDR
g3ipUDRcGDben/16KL6K5Og5i0pGww5vYqvgHEtFnCVI+hhn2zd980b5skERJHmg
Gelm/QWH974Nb01akww=
-----END PUBLIC KEY-----
      EOB
    }
    let(:public_key){
      OpenSSL::PKey::EC.new(public_key_str)
    }
    let(:public_key_blob){
      [
        HrrRbSsh::DataType::String.encode(public_key_algorithm_name),
        HrrRbSsh::DataType::String.encode(identifier),
        HrrRbSsh::DataType::String.encode(public_key.public_key.to_bn.to_s(2)),
      ].join
    }

    context "with correct arguments" do
      context "when public_key is an instance of String" do
        it "returns true" do
          expect(algorithm.verify_public_key public_key_algorithm_name, public_key_str, public_key_blob).to be true
        end
      end

      context "when public_key is an instance of OpenSSL::PKey::EC" do
        it "returns true" do
          expect(algorithm.verify_public_key public_key_algorithm_name, public_key, public_key_blob).to be true
        end
      end
    end

    context "with incorrect arguments" do
      context "when public_key_algorithm_name is incorrect" do
        let(:incorrect_public_key_algorithm_name){ 'incorrect' }

        it "returns false" do
          expect(algorithm.verify_public_key incorrect_public_key_algorithm_name, public_key, public_key_blob).to be false
        end
      end

      context "when public_key is not an instance of neither String nor OpenSSL::PKey::EC" do
        let(:incorrect_public_key){ nil }

        it "returns false" do
          expect(algorithm.verify_public_key public_key_algorithm_name, incorrect_public_key, public_key_blob).to be false
        end
      end

      context "when public_key_blob is incorrect" do
        let(:incorrect_public_key_blob){ String.new }

        it "returns false" do
          expect(algorithm.verify_public_key public_key_algorithm_name, public_key, incorrect_public_key_blob).to be false
        end
      end
    end
  end

  describe '#verify_signature' do
    let(:private_key_str){
      <<-'EOB'
-----BEGIN EC PARAMETERS-----
BgUrgQQAIw==
-----END EC PARAMETERS-----
-----BEGIN EC PRIVATE KEY-----
MIHcAgEBBEIB8r5LkYGDpF6eSza+oXlvSSrDkdrm+LuEBpE0QYwFARGlDZ9A3iDU
ssFpF3/Vsln0t3X1NN87N670IbzjtaiBcBqgBwYFK4EEACOhgYkDgYYABABanKNh
2+CTX6TnTb1e/L0lEpE9uby+Mnc4I7ly0mQGjwQnP2auD3jfINLs/OJujA7wCueT
NUtsquGFd9Era2mi5gD4INGDeKlQNFwYNt6f/Xoovork6DmLSkbDDm9iq+AcS0Wc
JUj6GGfbN33zRvmyQREkeaAZ6Wb9BYf3vg1vTVqTDA==
-----END EC PRIVATE KEY-----
      EOB
    }
    let(:pkey){ OpenSSL::PKey::EC.new private_key_str }
    let(:public_key_blob){
      [
        HrrRbSsh::DataType::String.encode(name),
        HrrRbSsh::DataType::String.encode(identifier),
        HrrRbSsh::DataType::String.encode(pkey.public_key.to_bn.to_s(2)),
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
      let(:hash){ OpenSSL::Digest.digest(digest, data) }
      let(:sign_der){ pkey.dsa_sign_asn1(hash) }
      let(:sign_asn1){ OpenSSL::ASN1.decode(sign_der) }
      let(:sign_r){ sign_asn1.value[0].value.to_i }
      let(:sign_s){ sign_asn1.value[1].value.to_i }
      let(:signature_blob){
        [
          HrrRbSsh::DataType::Mpint.encode(sign_r),
          HrrRbSsh::DataType::Mpint.encode(sign_s),
        ].join
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
      let(:hash){ OpenSSL::Digest.digest(digest, data) }
      let(:sign_der){ pkey.dsa_sign_asn1(hash) }
      let(:sign_asn1){ OpenSSL::ASN1.decode(sign_der) }
      let(:sign_r){ sign_asn1.value[0].value.to_i }
      let(:sign_s){ sign_asn1.value[1].value.to_i }
      let(:signature_blob){
        [
          HrrRbSsh::DataType::Mpint.encode(sign_r),
          HrrRbSsh::DataType::Mpint.encode(sign_s),
        ].join
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
      let(:hash){ OpenSSL::Digest.digest(digest, data) }
      let(:sign_der){ pkey.dsa_sign_asn1(hash) }
      let(:sign_asn1){ OpenSSL::ASN1.decode(sign_der) }
      let(:sign_r){ sign_asn1.value[0].value.to_i }
      let(:sign_s){ sign_asn1.value[1].value.to_i }
      let(:signature_blob){
        [
          HrrRbSsh::DataType::Mpint.encode(sign_r),
          HrrRbSsh::DataType::Mpint.encode(sign_s),
        ].join
      }
      let(:incorrect_signature_blob){ HrrRbSsh::DataType::Mpint.encode(12345) + signature_blob }
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
