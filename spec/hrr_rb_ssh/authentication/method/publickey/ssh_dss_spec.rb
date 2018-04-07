# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Authentication::Method::Publickey::SshDss do
  let(:publickey){ described_class.new }

  it "is registered as ssh-dss in HrrRbSsh::Authentication::Method::Publickey.list" do
    expect( HrrRbSsh::Authentication::Method::Publickey['ssh-dss'] ).to eq described_class
  end

  it "appears as ssh-dss in HrrRbSsh::Authentication::Method::Publickey.name_list" do
    expect( HrrRbSsh::Authentication::Method::Publickey.algorithm_name_list ).to include 'ssh-dss'
  end

  describe "::NAME" do
    it "is \"ssh-dss\"" do
      expect( described_class::NAME ).to eq 'ssh-dss'
    end
  end

  describe "::DIGEST" do
    it "is \"sha1\"" do
      expect( described_class::DIGEST ).to eq 'sha1'
    end
  end

  describe '#verify_public_key' do
    let(:public_key_algorithm_name){ 'ssh-dss' }
    let(:public_key_str){
      <<-'EOB'
-----BEGIN PUBLIC KEY-----
MIIBtzCCASwGByqGSM44BAEwggEfAoGBAKh2ZJp4ao8Xaexa0sk68VqMCaOaTi19
YIqo2+t2t8ve4QSHvk/NbFIDTGq90lHziakTqwKaaswWLB7cSRPTcXjLv16Zmazg
JRvh1jZ3ikuBME2G/B+EptlQ00dMa+5W/Acp2P6Cv5NRgA/tx0AyCJaItSpLXG+k
B+HMp9LQ8WotAhUAk/yyvpsY9sVSyeN3lHvg5Nsl568CgYEAj4rqF241ROP2olNh
VJUF0K5N4dSBCfcPnSPYuGPCi7qV229RISET3LOwrCXEUwSwlKoe/lLb2mcaeC84
NIeN6pQnRTE6zajJ9UUeGErOFRm1x6E+FMtlVp/fwUE1Ra+AscHVKwMUehz7sA6A
ZxJK7UvLs+R6s1eYhrES0bcorLIDgYQAAoGAd6XKzevlwzt6aCYdBRdN+BT4BQUw
/L3MVYG0kDV9WqPcyAFvLO54xAUf9LxYM0e8X8J5ECp4oEGOcK1ilXEw3LPMJGmY
IB56R9izS1t636kxnJTYNGQY+XvjAeuP7nC2WVNHNz7vXprT4Sq+hQaNkaKPu/3/
48xJs2mYbxfyHCQ=
-----END PUBLIC KEY-----
      EOB
    }
    let(:public_key){
      OpenSSL::PKey::DSA.new(public_key_str)
    }
    let(:public_key_blob){
      [
        HrrRbSsh::Transport::DataType::String.encode('ssh-dss'),
        HrrRbSsh::Transport::DataType::Mpint.encode(public_key.p.to_i),
        HrrRbSsh::Transport::DataType::Mpint.encode(public_key.q.to_i),
        HrrRbSsh::Transport::DataType::Mpint.encode(public_key.g.to_i),
        HrrRbSsh::Transport::DataType::Mpint.encode(public_key.pub_key.to_i),
      ].join
    }

    context "with correct arguments" do
      context "when public_key is an instance of String" do
        it "returns true" do
          expect(publickey.verify_public_key public_key_algorithm_name, public_key_str, public_key_blob).to be true
        end
      end

      context "when public_key is an instance of OpenSSL::PKey::DSA" do
        it "returns true" do
          expect(publickey.verify_public_key public_key_algorithm_name, public_key, public_key_blob).to be true
        end
      end
    end

    context "with incorrect arguments" do
      context "when public_key_algorithm_name is incorrect" do
        let(:incorrect_public_key_algorithm_name){ 'incorrect' }

        it "returns false" do
          expect(publickey.verify_public_key incorrect_public_key_algorithm_name, public_key, public_key_blob).to be false
        end
      end

      context "when public_key is not an instance of neither String nor OpenSSL::PKey::DSA" do
        let(:incorrect_public_key){ nil }

        it "returns false" do
          expect(publickey.verify_public_key public_key_algorithm_name, incorrect_public_key, public_key_blob).to be false
        end
      end

      context "when public_key_blob is broken" do
        let(:broken_public_key_blob){ String.new }

        it "returns false" do
          expect(publickey.verify_public_key public_key_algorithm_name, public_key, broken_public_key_blob).to be false
        end
      end
    end
  end

  describe '#verify_signature' do
    let(:private_key_str){
      <<-'EOB'
-----BEGIN DSA PRIVATE KEY-----
MIIBuwIBAAKBgQCodmSaeGqPF2nsWtLJOvFajAmjmk4tfWCKqNvrdrfL3uEEh75P
zWxSA0xqvdJR84mpE6sCmmrMFiwe3EkT03F4y79emZms4CUb4dY2d4pLgTBNhvwf
hKbZUNNHTGvuVvwHKdj+gr+TUYAP7cdAMgiWiLUqS1xvpAfhzKfS0PFqLQIVAJP8
sr6bGPbFUsnjd5R74OTbJeevAoGBAI+K6hduNUTj9qJTYVSVBdCuTeHUgQn3D50j
2Lhjwou6ldtvUSEhE9yzsKwlxFMEsJSqHv5S29pnGngvODSHjeqUJ0UxOs2oyfVF
HhhKzhUZtcehPhTLZVaf38FBNUWvgLHB1SsDFHoc+7AOgGcSSu1Ly7PkerNXmIax
EtG3KKyyAoGAd6XKzevlwzt6aCYdBRdN+BT4BQUw/L3MVYG0kDV9WqPcyAFvLO54
xAUf9LxYM0e8X8J5ECp4oEGOcK1ilXEw3LPMJGmYIB56R9izS1t636kxnJTYNGQY
+XvjAeuP7nC2WVNHNz7vXprT4Sq+hQaNkaKPu/3/48xJs2mYbxfyHCQCFCoAkEnN
yFHINL3X2CjZDKKLJ2Fl
-----END DSA PRIVATE KEY-----
      EOB
    }
    let(:algorithm){ OpenSSL::PKey::DSA.new private_key_str }
    let(:public_key_blob){
      [
        HrrRbSsh::Transport::DataType::String.encode('ssh-dss'),
        HrrRbSsh::Transport::DataType::Mpint.encode(algorithm.p.to_i),
        HrrRbSsh::Transport::DataType::Mpint.encode(algorithm.q.to_i),
        HrrRbSsh::Transport::DataType::Mpint.encode(algorithm.g.to_i),
        HrrRbSsh::Transport::DataType::Mpint.encode(algorithm.pub_key.to_i),
      ].join
    }
    let(:session_id){ 'session id' }
    let(:username){ 'username' }
    let(:message){
      {
      'session identifier'        => session_id,
      'message number'            => HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
      'user name'                 => username,
      'service name'              => 'ssh-connection',
      'method name'               => 'publickey',
      'with signature'            => true,
      'public key algorithm name' => 'ssh-dss',
      'public key blob'           => public_key_blob,
      'signature'                 => signature,
      }
    }
    let(:data){
      [
        HrrRbSsh::Transport::DataType::String.encode(session_id),
        HrrRbSsh::Transport::DataType::Byte.encode(HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE),
        HrrRbSsh::Transport::DataType::String.encode(username),
        HrrRbSsh::Transport::DataType::String.encode('ssh-connection'),
        HrrRbSsh::Transport::DataType::String.encode('publickey'),
        HrrRbSsh::Transport::DataType::Boolean.encode(true),
        HrrRbSsh::Transport::DataType::String.encode('ssh-dss'),
        HrrRbSsh::Transport::DataType::String.encode(public_key_blob),
      ].join
    }

    context "with correct signature" do
      let(:hash){ OpenSSL::Digest.digest('sha1', data) }
      let(:sign_der){ algorithm.syssign(hash) }
      let(:sign_asn1){ OpenSSL::ASN1.decode(sign_der) }
      let(:sign_r){ sign_asn1.value[0].value.to_s(2).rjust(20, ["00"].pack("H")) }
      let(:sign_s){ sign_asn1.value[1].value.to_s(2).rjust(20, ["00"].pack("H")) }
      let(:signature_blob){ sign_r + sign_s }
      let(:signature){
        [
          HrrRbSsh::Transport::DataType::String.encode('ssh-dss'),
          HrrRbSsh::Transport::DataType::String.encode(signature_blob),
        ].join
      }

      it "returns true" do
        expect( publickey.verify_signature(session_id, message) ).to be true
      end
    end

    context "with incorrect algorithm" do
      let(:hash){ OpenSSL::Digest.digest('sha1', data) }
      let(:sign_der){ algorithm.syssign(hash) }
      let(:sign_asn1){ OpenSSL::ASN1.decode(sign_der) }
      let(:sign_r){ sign_asn1.value[0].value.to_s(2).rjust(20, ["00"].pack("H")) }
      let(:sign_s){ sign_asn1.value[1].value.to_s(2).rjust(20, ["00"].pack("H")) }
      let(:signature_blob){ sign_r + sign_s }
      let(:signature){
        [
          HrrRbSsh::Transport::DataType::String.encode('incorrect'),
          HrrRbSsh::Transport::DataType::String.encode(signature_blob),
        ].join
      }

      it "returns false" do
        expect( publickey.verify_signature(session_id, message) ).to be false
      end
    end

    context "with incorrect signature" do
      let(:hash){ OpenSSL::Digest.digest('sha1', data) }
      let(:sign_der){ algorithm.syssign(hash) }
      let(:sign_asn1){ OpenSSL::ASN1.decode(sign_der) }
      let(:sign_r){ sign_asn1.value[0].value.to_s(2).rjust(20, ["00"].pack("H")) }
      let(:sign_s){ sign_asn1.value[1].value.to_s(2).rjust(20, ["00"].pack("H")) }
      let(:signature_blob){ sign_r + sign_s }
      let(:incorrect_signature_blob){ 'incorrect' + signature_blob }
      let(:signature){
        [
          HrrRbSsh::Transport::DataType::String.encode('ssh-dss'),
          HrrRbSsh::Transport::DataType::String.encode(incorrect_signature_blob),
        ].join
      }

      it "returns false" do
        expect( publickey.verify_signature(session_id, message) ).to be false
      end
    end
  end
end
