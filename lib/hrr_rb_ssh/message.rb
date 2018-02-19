# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  module Message
    @@ssh_msg_list ||= Hash.new

    def self.[] key
      @@ssh_msg_list[key]
    end
  end
end
