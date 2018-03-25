# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Connection::Channel::Session do
  it "is registered as \"session\" in HrrRbSsh::Connection::Channel.type_list" do
    expect( HrrRbSsh::Connection::Channel['session'] ).to eq described_class
  end

  it "appears as \"session\" in HrrRbSsh::Connection::Channel.type_list" do
    expect( HrrRbSsh::Connection::Channel.type_list ).to include 'session'
  end
end
