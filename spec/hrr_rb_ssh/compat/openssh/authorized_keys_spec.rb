# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Compat::OpenSSH::AuthorizedKeys do
  let(:authorized_keys){ described_class.new authorized_keys_str }
  let(:authorized_keys_str){
    <<-'EOB'
ssh-dss AAAAB3NzaC1kc3MAAACBAPjl4V54N5zajrsn89N1nAQ1rBDFJ8FeXpfvCved1fW9Fxpv8wzwk7zsj5nTD+ZejojBSjEi0cdkeE6q+O6bHfO8r5kzLKkovFMQwxSwxHpz9etjm0rXvIDZV3cISRd2UhaUR4T/2mJ3fYvYfE2YbrK5gPdhqHaufCjhXHivnsZvAAAAFQDOudgAp+P+2AJnw1cBY+kUQkd5nQAAAIApiSanwbzT553W+6Te3LADV4+SPzutm5rhaRV0nanFAc5a9pMA4ZmKY/0yrRFQYECdW/21/jHzNIsr8Wcx2jcvRRy6PI89KS5mJc+1Mr7gq+JMg9xotyBXGauWmUv+CllC/6fatJLpc1kKkmxmvLe/ygcjU5RKggN9nWXSXgB1iQAAAIEAgbOvSWV6PdnJfbPPCT5bv+ezKy1SmBRHpFz12LTnlSCPliT1mPJgV6GZEH5UpuQJdSf9jmytKS1dub1/ST47mKw3VKq1/UplFO2/np7D/Kqlz2lUT3ox4q1bWaX+7cq7wUL8YqVBmUIZSYSJhyE1oTtFnJUGmCqNrkKWKXZQ+r4= username@hostname
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQC1dcoK+HfrtPNBhBhq+Z4C5Qpy5aEH1mTfFGzfDYfWxa2OY+8mxTSAgYdQipYY2KwL85u2zXicAXL0Qjn91eNUcyIPnDPZydg4z7dj5R6g6vB8xCBfa7iUY0eXpv2UblELOn46CNyL4L+ysqYyfvhx+eyyklsFWH4JuE4f4/7VoQ== username@hostname
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDB74hIIITiludl3RZ9kTqZHxHMrvvNF+ILo3yk92BXQ4YZqj/oahIHl9c+BUZXsSdRiqKuu2DcXhhCf34hPicNUoYzmbHi2GBhh6r/mjXqMYuMWBZjL0r34KTBHhB4gWcjFdM+NRfGe7Xg6TU2fTd3Hbw/hQHUQLxAU5IfpWwAdpc+HtbkyBFPICCZ1u9tAQRbJePpHsDgZYaeIvUCvOWg6qp+qG+4z87kKHmm/nIIC8/LFux6z74729na3DIKEP/olLej9Qb8GSPN4Qbe6Dtq+RB7qBpWDBne2NpdvBU1FJHQRCWrgmkXE6m9fgwGASn06OT7FiqyHMoSbG+p8fKj username@hostname
ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBJPJuePF4GvlxhJkcez+9cRpcQn4Iz4911TsPn1z10YANN2ucgyRKTn3qLCTjvbcHqw+6T4Zl0RJMoG5T7BF2lQ= username@hostname
ecdsa-sha2-nistp384 AAAAE2VjZHNhLXNoYTItbmlzdHAzODQAAAAIbmlzdHAzODQAAABhBKHlutI8luFWl4nXcXq3AgnnbLgmaYDCowk8csd3XbAQBJdV5fXm5nRNrvL9EMNBBkf/E+rRmqsbiAZkOucXU+c1Ed2fYEHGOqvMIUs8/WwAf/C0V3rZh8qN+WzZr9wcWA== username@hostname
ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBACecu7a4bXhp4hFCIMIeYvAGlip0mgU0bMckT7UPuNQEbSXXSDHrTWeXFRcBO/VXPNs0BSX1IWQRFFntkx8Re7XNQGnuaeYuXeoULNIvrLoKK4rxXCb3RfGjBrGqTgeGFnFB1JBOPzQPYSyQaaXhsqP5DftAMPodFwvWLDAxCamrs0acg== username@hostname
    EOB
  }

  describe ".new" do
    it "does not raises error" do
      expect { authorized_keys }.not_to raise_error
    end
  end

  describe "#each" do
    it "iterates each line with public key variable" do
      expect(authorized_keys.map{|public_key| public_key.algorithm_name}).to match ["ssh-dss", "ssh-rsa", "ssh-rsa", "ecdsa-sha2-nistp256", "ecdsa-sha2-nistp384", "ecdsa-sha2-nistp521"]
    end
  end
end
