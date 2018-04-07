# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Connection::Channel::ChannelType::Session do
  let(:name){ 'session' }

  it "is registered in HrrRbSsh::Connection::Channel::ChannelType.list" do
    expect( HrrRbSsh::Connection::Channel::ChannelType.list ).to include described_class
  end

  it "can be looked up in HrrRbSsh::Connection::Channel::ChannelType dictionary" do
    expect( HrrRbSsh::Connection::Channel::ChannelType[name] ).to eq described_class
  end

  it "appears in HrrRbSsh::Connection::Channel::ChannelType.name_list" do
    expect( HrrRbSsh::Connection::Channel::ChannelType.name_list ).to include name
  end
end
