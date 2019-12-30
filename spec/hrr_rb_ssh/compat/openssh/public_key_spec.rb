# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Compat::OpenSSH::PublicKey do
  let(:public_key){ described_class.new public_key_line }

  context "when data_line is \"ssh-dss\"" do
    let(:algorithm_name){ "ssh-dss" }
    let(:public_key_line){
      "ssh-dss AAAAB3NzaC1kc3MAAACBAPjl4V54N5zajrsn89N1nAQ1rBDFJ8FeXpfvCved1fW9Fxpv8wzwk7zsj5nTD+ZejojBSjEi0cdkeE6q+O6bHfO8r5kzLKkovFMQwxSwxHpz9etjm0rXvIDZV3cISRd2UhaUR4T/2mJ3fYvYfE2YbrK5gPdhqHaufCjhXHivnsZvAAAAFQDOudgAp+P+2AJnw1cBY+kUQkd5nQAAAIApiSanwbzT553W+6Te3LADV4+SPzutm5rhaRV0nanFAc5a9pMA4ZmKY/0yrRFQYECdW/21/jHzNIsr8Wcx2jcvRRy6PI89KS5mJc+1Mr7gq+JMg9xotyBXGauWmUv+CllC/6fatJLpc1kKkmxmvLe/ygcjU5RKggN9nWXSXgB1iQAAAIEAgbOvSWV6PdnJfbPPCT5bv+ezKy1SmBRHpFz12LTnlSCPliT1mPJgV6GZEH5UpuQJdSf9jmytKS1dub1/ST47mKw3VKq1/UplFO2/np7D/Kqlz2lUT3ox4q1bWaX+7cq7wUL8YqVBmUIZSYSJhyE1oTtFnJUGmCqNrkKWKXZQ+r4= username@hostname"
    }
    let(:public_key_pem){
      <<-'EOB'
-----BEGIN PUBLIC KEY-----
MIIBtzCCASsGByqGSM44BAEwggEeAoGBAPjl4V54N5zajrsn89N1nAQ1rBDFJ8Fe
XpfvCved1fW9Fxpv8wzwk7zsj5nTD+ZejojBSjEi0cdkeE6q+O6bHfO8r5kzLKko
vFMQwxSwxHpz9etjm0rXvIDZV3cISRd2UhaUR4T/2mJ3fYvYfE2YbrK5gPdhqHau
fCjhXHivnsZvAhUAzrnYAKfj/tgCZ8NXAWPpFEJHeZ0CgYApiSanwbzT553W+6Te
3LADV4+SPzutm5rhaRV0nanFAc5a9pMA4ZmKY/0yrRFQYECdW/21/jHzNIsr8Wcx
2jcvRRy6PI89KS5mJc+1Mr7gq+JMg9xotyBXGauWmUv+CllC/6fatJLpc1kKkmxm
vLe/ygcjU5RKggN9nWXSXgB1iQOBhQACgYEAgbOvSWV6PdnJfbPPCT5bv+ezKy1S
mBRHpFz12LTnlSCPliT1mPJgV6GZEH5UpuQJdSf9jmytKS1dub1/ST47mKw3VKq1
/UplFO2/np7D/Kqlz2lUT3ox4q1bWaX+7cq7wUL8YqVBmUIZSYSJhyE1oTtFnJUG
mCqNrkKWKXZQ+r4=
-----END PUBLIC KEY-----
      EOB
    }

    describe ".new" do
      it "does not raises error" do
        expect { public_key }.not_to raise_error
      end
    end

    describe "#algorithm_name" do
      it "returns correct algorithm name" do
        expect(public_key.algorithm_name).to eq algorithm_name
      end
    end

    describe "#to_pem" do
      it "returns correct public key in PEM format" do
        expect(public_key.to_pem).to eq public_key_pem
      end
    end
  end

  context "when data_line is \"ssh-rsa\" (1024 bits)" do
    let(:algorithm_name){ "ssh-rsa" }
    let(:public_key_line){
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQC1dcoK+HfrtPNBhBhq+Z4C5Qpy5aEH1mTfFGzfDYfWxa2OY+8mxTSAgYdQipYY2KwL85u2zXicAXL0Qjn91eNUcyIPnDPZydg4z7dj5R6g6vB8xCBfa7iUY0eXpv2UblELOn46CNyL4L+ysqYyfvhx+eyyklsFWH4JuE4f4/7VoQ== username@hostname"
    }
    let(:public_key_pem){
      <<-'EOB'
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC1dcoK+HfrtPNBhBhq+Z4C5Qpy
5aEH1mTfFGzfDYfWxa2OY+8mxTSAgYdQipYY2KwL85u2zXicAXL0Qjn91eNUcyIP
nDPZydg4z7dj5R6g6vB8xCBfa7iUY0eXpv2UblELOn46CNyL4L+ysqYyfvhx+eyy
klsFWH4JuE4f4/7VoQIDAQAB
-----END PUBLIC KEY-----
      EOB
    }

    describe ".new" do
      it "does not raises error" do
        expect { public_key }.not_to raise_error
      end
    end

    describe "#algorithm_name" do
      it "returns correct algorithm name" do
        expect(public_key.algorithm_name).to eq algorithm_name
      end
    end

    describe "#to_pem" do
      it "returns correct public key in PEM format" do
        expect(public_key.to_pem).to eq public_key_pem
      end
    end
  end

  context "when data_line is \"ssh-rsa\" (2048 bits)" do
    let(:algorithm_name){ "ssh-rsa" }
    let(:public_key_line){
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDB74hIIITiludl3RZ9kTqZHxHMrvvNF+ILo3yk92BXQ4YZqj/oahIHl9c+BUZXsSdRiqKuu2DcXhhCf34hPicNUoYzmbHi2GBhh6r/mjXqMYuMWBZjL0r34KTBHhB4gWcjFdM+NRfGe7Xg6TU2fTd3Hbw/hQHUQLxAU5IfpWwAdpc+HtbkyBFPICCZ1u9tAQRbJePpHsDgZYaeIvUCvOWg6qp+qG+4z87kKHmm/nIIC8/LFux6z74729na3DIKEP/olLej9Qb8GSPN4Qbe6Dtq+RB7qBpWDBne2NpdvBU1FJHQRCWrgmkXE6m9fgwGASn06OT7FiqyHMoSbG+p8fKj username@hostname"
    }
    let(:public_key_pem){
      <<-'EOB'
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwe+ISCCE4pbnZd0WfZE6
mR8RzK77zRfiC6N8pPdgV0OGGao/6GoSB5fXPgVGV7EnUYqirrtg3F4YQn9+IT4n
DVKGM5mx4thgYYeq/5o16jGLjFgWYy9K9+CkwR4QeIFnIxXTPjUXxnu14Ok1Nn03
dx28P4UB1EC8QFOSH6VsAHaXPh7W5MgRTyAgmdbvbQEEWyXj6R7A4GWGniL1Arzl
oOqqfqhvuM/O5Ch5pv5yCAvPyxbses++O9vZ2twyChD/6JS3o/UG/BkjzeEG3ug7
avkQe6gaVgwZ3tjaXbwVNRSR0EQlq4JpFxOpvX4MBgEp9Ojk+xYqshzKEmxvqfHy
owIDAQAB
-----END PUBLIC KEY-----
      EOB
    }

    describe ".new" do
      it "does not raises error" do
        expect { public_key }.not_to raise_error
      end
    end

    describe "#algorithm_name" do
      it "returns correct algorithm name" do
        expect(public_key.algorithm_name).to eq algorithm_name
      end
    end

    describe "#to_pem" do
      it "returns correct public key in PEM format" do
        expect(public_key.to_pem).to eq public_key_pem
      end
    end
  end

  context "when data_line is \"ecdsa-sha2-nistp256\"" do
    let(:algorithm_name){ "ecdsa-sha2-nistp256" }
    let(:public_key_line){
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBJPJuePF4GvlxhJkcez+9cRpcQn4Iz4911TsPn1z10YANN2ucgyRKTn3qLCTjvbcHqw+6T4Zl0RJMoG5T7BF2lQ= username@hostname"
    }
    let(:public_key_pem){
      <<-'EOB'
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEk8m548Xga+XGEmRx7P71xGlxCfgj
Pj3XVOw+fXPXRgA03a5yDJEpOfeosJOO9twerD7pPhmXREkygblPsEXaVA==
-----END PUBLIC KEY-----
      EOB
    }

    describe ".new" do
      it "does not raises error" do
        expect { public_key }.not_to raise_error
      end
    end

    describe "#algorithm_name" do
      it "returns correct algorithm name" do
        expect(public_key.algorithm_name).to eq algorithm_name
      end
    end

    describe "#to_pem" do
      it "returns correct public key in PEM format" do
        expect(public_key.to_pem).to eq public_key_pem
      end
    end
  end

  context "when data_line is \"ecdsa-sha2-nistp384\"" do
    let(:algorithm_name){ "ecdsa-sha2-nistp384" }
    let(:public_key_line){
      "ecdsa-sha2-nistp384 AAAAE2VjZHNhLXNoYTItbmlzdHAzODQAAAAIbmlzdHAzODQAAABhBKHlutI8luFWl4nXcXq3AgnnbLgmaYDCowk8csd3XbAQBJdV5fXm5nRNrvL9EMNBBkf/E+rRmqsbiAZkOucXU+c1Ed2fYEHGOqvMIUs8/WwAf/C0V3rZh8qN+WzZr9wcWA== username@hostname"
    }
    let(:public_key_pem){
      <<-'EOB'
-----BEGIN PUBLIC KEY-----
MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEoeW60jyW4VaXiddxercCCedsuCZpgMKj
CTxyx3ddsBAEl1Xl9ebmdE2u8v0Qw0EGR/8T6tGaqxuIBmQ65xdT5zUR3Z9gQcY6
q8whSzz9bAB/8LRXetmHyo35bNmv3BxY
-----END PUBLIC KEY-----
      EOB
    }

    describe ".new" do
      it "does not raises error" do
        expect { public_key }.not_to raise_error
      end
    end

    describe "#algorithm_name" do
      it "returns correct algorithm name" do
        expect(public_key.algorithm_name).to eq algorithm_name
      end
    end

    describe "#to_pem" do
      it "returns correct public key in PEM format" do
        expect(public_key.to_pem).to eq public_key_pem
      end
    end
  end

  context "when data_line is \"ecdsa-sha2-nistp521\"" do
    let(:algorithm_name){ "ecdsa-sha2-nistp521" }
    let(:public_key_line){
      "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBACecu7a4bXhp4hFCIMIeYvAGlip0mgU0bMckT7UPuNQEbSXXSDHrTWeXFRcBO/VXPNs0BSX1IWQRFFntkx8Re7XNQGnuaeYuXeoULNIvrLoKK4rxXCb3RfGjBrGqTgeGFnFB1JBOPzQPYSyQaaXhsqP5DftAMPodFwvWLDAxCamrs0acg== username@hostname"
    }
    let(:public_key_pem){
      <<-'EOB'
-----BEGIN PUBLIC KEY-----
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAnnLu2uG14aeIRQiDCHmLwBpYqdJo
FNGzHJE+1D7jUBG0l10gx601nlxUXATv1VzzbNAUl9SFkERRZ7ZMfEXu1zUBp7mn
mLl3qFCzSL6y6CiuK8Vwm90Xxowaxqk4HhhZxQdSQTj80D2EskGml4bKj+Q37QDD
6HRcL1iwwMQmpq7NGnI=
-----END PUBLIC KEY-----
      EOB
    }

    describe ".new" do
      it "does not raises error" do
        expect { public_key }.not_to raise_error
      end
    end

    describe "#algorithm_name" do
      it "returns correct algorithm name" do
        expect(public_key.algorithm_name).to eq algorithm_name
      end
    end

    describe "#to_pem" do
      it "returns correct public key in PEM format" do
        expect(public_key.to_pem).to eq public_key_pem
      end
    end
  end
end
