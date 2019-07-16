# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Authentication::Method::Publickey::Algorithm::EcdsaSha2Nistp384 do
  let(:name){ 'ecdsa-sha2-nistp384' }
  let(:digest){ 'sha384' }
  let(:identifier){ 'nistp384' }
  let(:curve_name){ 'secp384r1' }
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
MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEvPAtRzwbLtkZaDXmsZGLNq7g1cgTd1CL
iVYOlpY7+r149eKPqpKi+Qf4u0Nbds+/ozDBNcVkKGsEusV2YzVgMa2jh2w12zFH
CLUB5L9+lZRpEt0ux9N4NgAi8mcb/9va
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
    end

    context "with incorrect arguments" do
      context "when public_key_algorithm_name is incorrect" do
        let(:incorrect_public_key_algorithm_name){ 'incorrect' }

        it "returns false" do
          expect(algorithm.verify_public_key incorrect_public_key_algorithm_name, public_key_str, public_key_blob).to be false
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
          expect(algorithm.verify_public_key public_key_algorithm_name, public_key_str, incorrect_public_key_blob).to be false
        end
      end
    end
  end

  describe '#verify_signature' do
    let(:private_key_str){
      <<-'EOB'
-----BEGIN EC PARAMETERS-----
BgUrgQQAIg==
-----END EC PARAMETERS-----
-----BEGIN EC PRIVATE KEY-----
MIGkAgEBBDAKi6ERSFNJ6HcNm4Rr35sLlUfGDN+Ztc7Pj4XFdCupAQzDLzXUee1C
S+MJB8pw3bGgBwYFK4EEACKhZANiAAS88C1HPBsu2RloNeaxkYs2ruDVyBN3UIuJ
Vg6Wljv6vXj14o+qkqL5B/i7Q1t2z7+jMME1xWQoawS6xXZjNWAxraOHbDXbMUcI
tQHkv36VlGkS3S7H03g2ACLyZxv/29o=
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
