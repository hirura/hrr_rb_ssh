# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Connection::Channel::ChannelType::Session do
  let(:name){ 'session' }

  it "can be looked up in HrrRbSsh::Connection::Channel::ChannelType dictionary" do
    expect( HrrRbSsh::Connection::Channel::ChannelType[name] ).to be described_class
  end
end
