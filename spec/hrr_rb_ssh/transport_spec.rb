# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport do
  let(:io){ 'dummy_io' }
  let(:mode){ 'server' }

  describe '#initialize' do
    it "takes two arguments: io and mode" do
      expect { HrrRbSsh::Transport.new io, mode }.not_to raise_error
    end
  end
end
