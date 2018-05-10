# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport::ServerHostKeyAlgorithm::SshRsa do
  let(:name){ 'ssh-rsa' }

  it "can be looked up in HrrRbSsh::Transport::ServerHostKeyAlgorithm dictionary" do
    expect( HrrRbSsh::Transport::ServerHostKeyAlgorithm[name] ).to eq described_class
  end       

  it "is registered in HrrRbSsh::Transport::ServerHostKeyAlgorithm.list_supported" do
    expect( HrrRbSsh::Transport::ServerHostKeyAlgorithm.list_supported ).to include name
  end         

  it "appears in HrrRbSsh::Transport::ServerHostKeyAlgorithm.list_preferred" do
    expect( HrrRbSsh::Transport::ServerHostKeyAlgorithm.list_preferred ).to include name
  end

  context "when secret_key is specified" do
    let(:server_host_key_algorithm){ described_class.new secret_key }
    let(:secret_key){
      <<-'EOB'
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA71zHt9RvbXmxuOCWPKR65iBHO+a8M7Mfo4vRCs/dorZN7XL1
lYwjclvo0X1T39BRX+qJ2m4HB+7Vlef9YF7spYKm6czuSCYmJjD5X+PW5QYSGED1
fFSXwjTdDwJi1OKS4kL0Dd6zcSjlFxfjVLNCyUcix36XgDpoBLBFkDZd5P2ow3J6
WNanBasXrckjCk4M3kFclvmxl1O56bbV9VZq51ZqLjv/ZhOrE3WIPfrJGdZssODa
DnI6tM1puwZGVba9VaI8FfnuJcacJ3T9oEoXPY5W+kPZAw6dOARXnJTg+oZk/dBD
Bgej0aMO+1XM7HKz5BiqbhGGSXGas5zoefHbNwIDAQABAoIBAQDP2aQ/2EOuL8eI
/9TV8goafRr+RB1XU4r8zHOIzPnryhyfPX1OEDPToUXpa8gCiPWwsYxlVbfbRqTH
mHzoS2V5T5u7WE3t7tqfvVU+1C0OERhzYS0KeraRWLBA0VSbAeiEe5lL1f/CGr3c
MM0iBsvO1mu4ChBqs80RjTPKx7r/FStpWtqWN4kn+Bhj06qCqhftnudZdYFTHa/G
ia4YWOUH6dSIZKpE7oG53Gm/2ZdK2YiAgMOdrTQkvRzxuIa/RHaETj21hKpetmI7
TfS26RbU2t1Bf/fdFhtTqoAz+CrZEH7Z407ZO45fdc31zJAFIK2Zf3CDVnKwih3t
O0bEVSSpAoGBAP/zEWaTivdQtcemMRhFQBySgnStov+dsxnGBnTkWxVIU7VoFgyg
mgNRlWUxMf12mlfqBVRpx0/ALggHf5KFmbAZ+3qvKSLmfIVM5E9l5NKbZnCWtIqq
1DN9kHPPOZn3uYvOs9Cpn7S6sa+rVZ82Mg8EZMsPesvFMOjrgNbMQxt7AoGBAO9o
38VM0+M09sAgOhmqv+Esa2gUGw5n18o/fdmlZdnA+D2ntgr70AD6JUCSYrZgTJRq
HNMuKrbD6HyaPjVaxYJVCFJIcfV+nViZdE8cHh9WXQ/JP/T6nvNajCC8StvoQg4I
vAZFTzChoe2yrOsWXezn9QAecQ8L2WHDLImpayR1AoGADoc1jaUCVld2egas8ru7
j+OhFA5nGitRZz0eULRFl0eruLhXyA+1rkqLOFs6gzCgQi0+cDQw5A38jugeDasX
ti9DXwtiQmDi4I4kx3z5KBs6DVoAlX5s3R9be7dfhaXSGmV5P3bhYdjXDSmkio0A
+mk9b2lJhxeCVzZG8epWRNECgYB2KzGoVQ+Q6ieRFVcYLCuhnSc2rBXeumrMrSIV
N4paPOFKrWkxarF0igOxJ5AJrOafqvCnW/ZBV9l9BzUFaNRsTERbON7m6aQIg1Xh
ZmOH3Dz6+b7T0JB8VYks70OT38Qa4TzNa5B21JD0nmizcMrTkHphoKT1ZEfb9VYa
bMExsQKBgQDoSpo/ZP8+dwR1A/gcu2K5Ie47c3WgKw7qQMarxqzTeS8Xu6/KAn+J
Ka2zIvoHhxlhXFBRhp+FIaFlYRR38gHeNxCoUylpboCUyMkHOsOP43AiKsmbNK20
vzTNM3SFzgt3bHkdEtDLc64aoBX+dHOot6u71XLZrshnHPtiZ0C/ZA==
-----END RSA PRIVATE KEY-----
      EOB
    }


    describe '#server_public_host_key' do
      it "returns encoded \"ssh-rsa\" || e || n" do
        encoded_server_public_host_key = \
          "00000007" "7373682d" "72736100" "00000301" \
          "00010000" "010100ef" "5cc7b7d4" "6f6d79b1" \
          "b8e0963c" "a47ae620" "473be6bc" "33b31fa3" \
          "8bd10acf" "dda2b64d" "ed72f595" "8c23725b" \
          "e8d17d53" "dfd0515f" "ea89da6e" "0707eed5" \
          "95e7fd60" "5eeca582" "a6e9ccee" "48262626" \
          "30f95fe3" "d6e50612" "1840f57c" "5497c234" \
          "dd0f0262" "d4e292e2" "42f40dde" "b37128e5" \
          "1717e354" "b342c947" "22c77e97" "803a6804" \
          "b0459036" "5de4fda8" "c3727a58" "d6a705ab" \
          "17adc923" "0a4e0cde" "415c96f9" "b19753b9" \
          "e9b6d5f5" "566ae756" "6a2e3bff" "6613ab13" \
          "75883dfa" "c919d66c" "b0e0da0e" "723ab4cd" \
          "69bb0646" "55b6bd55" "a23c15f9" "ee25c69c" \
          "2774fda0" "4a173d8e" "56fa43d9" "030e9d38" \
          "04579c94" "e0fa8664" "fdd04306" "07a3d1a3" \
          "0efb55cc" "ec72b3e4" "18aa6e11" "8649719a" \
          "b39ce879" "f1db37"
        expect( server_host_key_algorithm.server_public_host_key ).to eq [encoded_server_public_host_key].pack("H*")
      end
    end

    describe '#sign' do
      let(:data){ 'testing' }

      it "returns encoded \"ssh-rsa\" || signed \"testing\"" do
        encoded_data = \
          "00000007" "7373682d" "72736100" "00010079" \
          "9e4cd767" "4c1c76af" "e67df9d9" "3654cf82" \
          "827510ae" "6918d691" "74112927" "872676dd" \
          "98bf6387" "8f10062a" "812bd1b7" "8932550e" \
          "74b494c5" "de4a03d3" "60f0d301" "21a0f87d" \
          "1dbce6f9" "383ac666" "564e76d9" "01f6c2a1" \
          "54629c90" "7a2745c1" "1682edae" "95788e34" \
          "ec0c0a62" "cafcd282" "a7b8a5df" "4ac4cf8f" \
          "d42d4ce3" "ee65e72e" "48a45518" "2529933f" \
          "9b680aa7" "a3201a0c" "1f07d483" "05f1d29e" \
          "8bcdb781" "316f0226" "7674ab17" "25924ece" \
          "22187ae0" "e7d1a226" "6f4cba54" "23f16734" \
          "bca97238" "89075e43" "c8815b62" "24cc7635" \
          "85895582" "007227e1" "b33a5c42" "1c3dfc04" \
          "331f6468" "bd557163" "b774360c" "2170dea0" \
          "372c761d" "52d896fa" "279f7071" "ac544d6d" \
          "a8b596f6" "6fdbd162" "60ee09e3" "c6b507"
        expect( server_host_key_algorithm.sign data ).to eq [encoded_data].pack("H*")
      end
    end

    describe '#verify' do
      let(:data){ 'testing' }

      context "with correct sign" do
        let(:encoded_data){
          "00000007" "7373682d" "72736100" "00010079" \
          "9e4cd767" "4c1c76af" "e67df9d9" "3654cf82" \
          "827510ae" "6918d691" "74112927" "872676dd" \
          "98bf6387" "8f10062a" "812bd1b7" "8932550e" \
          "74b494c5" "de4a03d3" "60f0d301" "21a0f87d" \
          "1dbce6f9" "383ac666" "564e76d9" "01f6c2a1" \
          "54629c90" "7a2745c1" "1682edae" "95788e34" \
          "ec0c0a62" "cafcd282" "a7b8a5df" "4ac4cf8f" \
          "d42d4ce3" "ee65e72e" "48a45518" "2529933f" \
          "9b680aa7" "a3201a0c" "1f07d483" "05f1d29e" \
          "8bcdb781" "316f0226" "7674ab17" "25924ece" \
          "22187ae0" "e7d1a226" "6f4cba54" "23f16734" \
          "bca97238" "89075e43" "c8815b62" "24cc7635" \
          "85895582" "007227e1" "b33a5c42" "1c3dfc04" \
          "331f6468" "bd557163" "b774360c" "2170dea0" \
          "372c761d" "52d896fa" "279f7071" "ac544d6d" \
          "a8b596f6" "6fdbd162" "60ee09e3" "c6b507"
        }
        let(:sign){ [encoded_data].pack("H*") }

        it "returns true" do
          expect( server_host_key_algorithm.verify sign, data ).to be true
        end
      end

      context "with not \"ssh-rsa\"" do
        let(:encoded_data){
          "00000007" "01234567" "01234500" "00010079" \
          "9e4cd767" "4c1c76af" "e67df9d9" "3654cf82" \
          "827510ae" "6918d691" "74112927" "872676dd" \
          "98bf6387" "8f10062a" "812bd1b7" "8932550e" \
          "74b494c5" "de4a03d3" "60f0d301" "21a0f87d" \
          "1dbce6f9" "383ac666" "564e76d9" "01f6c2a1" \
          "54629c90" "7a2745c1" "1682edae" "95788e34" \
          "ec0c0a62" "cafcd282" "a7b8a5df" "4ac4cf8f" \
          "d42d4ce3" "ee65e72e" "48a45518" "2529933f" \
          "9b680aa7" "a3201a0c" "1f07d483" "05f1d29e" \
          "8bcdb781" "316f0226" "7674ab17" "25924ece" \
          "22187ae0" "e7d1a226" "6f4cba54" "23f16734" \
          "bca97238" "89075e43" "c8815b62" "24cc7635" \
          "85895582" "007227e1" "b33a5c42" "1c3dfc04" \
          "331f6468" "bd557163" "b774360c" "2170dea0" \
          "372c761d" "52d896fa" "279f7071" "ac544d6d" \
          "a8b596f6" "6fdbd162" "60ee09e3" "c6b507"
        }
        let(:sign){ [encoded_data].pack("H*") }

        it "returns false" do
          expect( server_host_key_algorithm.verify sign, data ).to be false
        end
      end

      context "with incorrect sign" do
        let(:encoded_data){
          "00000007" "7373682d" "72736178" "12345678" \
          "12345678" "12345678" "12345678" "12345678" \
          "12345678" "12345678" "12345678" "12345678" \
          "12345678" "12345678" "12345678" "12345678" \
          "12345678" "12345678" "12345678" "12345678" \
          "12345678" "12345678" "12345678" "12345678" \
          "12345678" "12345678" "12345678" "12345678" \
          "12345678" "12345678" "12345678" "12345678" \
          "12345678" "12345678" "12345678" "12345678" \
          "12345678" "12345678" "12345678" "12345678" \
          "12345678" "12345678" "12345678" "12345678" \
          "12345678" "12345678" "12345678" "12345678" \
          "12345678" "12345678" "12345678" "12345678" \
          "12345678" "12345678" "12345678" "12345678" \
          "12345678" "12345678" "12345678" "12345678" \
          "12345678" "12345678" "12345678" "12345678" \
          "12345678" "12345678" "12345678" "123456"
        }
        let(:sign){ [encoded_data].pack("H*") }

        it "returns false" do
          expect( server_host_key_algorithm.verify sign, data ).to be false
        end
      end
    end
  end

  context "when secret_key is not specified" do
    let(:server_host_key_algorithm){ described_class.new }

    describe '#verify' do
      let(:data){ 'testing' }

      context "with correct sign" do
        let(:sign){ server_host_key_algorithm.sign(data) }

        it "returns true" do
          expect( server_host_key_algorithm.verify sign, data ).to be true
        end
      end
    end
  end
end
