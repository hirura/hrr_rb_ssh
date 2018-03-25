# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Connection::Channel::Session::PtyReq do
  it "is registered as \"pty-req\" in HrrRbSsh::Connection::Channel::Session.request_type_list" do
    expect( HrrRbSsh::Connection::Channel::Session['pty-req'] ).to eq described_class
  end

  it "appears as \"pty-req\" in HrrRbSsh::Connection::Channel::Session.request_type_list" do
    expect( HrrRbSsh::Connection::Channel::Session.request_type_list ).to include 'pty-req'
  end
end
