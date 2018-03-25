# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Connection do
  describe '.new' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ HrrRbSsh::Authentication.new transport }
    let(:options){ Hash.new }

    it "can take one argument: authentication" do
      expect { described_class.new(authentication) }.not_to raise_error
    end

    it "can take two arguments: authentication and options" do
      expect { described_class.new(authentication, options) }.not_to raise_error
    end
  end
end
