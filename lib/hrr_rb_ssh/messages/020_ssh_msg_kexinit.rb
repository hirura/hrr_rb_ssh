# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Messages
    class SSH_MSG_KEXINIT
      include Codable

      ID    = self.name.split('::').last
      VALUE = 20

      DEFINITION = [
        #[DataTypes, Field Name]
        [DataTypes::Byte,      :'message number'],
        [DataTypes::Byte,      :'cookie (random byte)'],
        [DataTypes::Byte,      :'cookie (random byte)'],
        [DataTypes::Byte,      :'cookie (random byte)'],
        [DataTypes::Byte,      :'cookie (random byte)'],
        [DataTypes::Byte,      :'cookie (random byte)'],
        [DataTypes::Byte,      :'cookie (random byte)'],
        [DataTypes::Byte,      :'cookie (random byte)'],
        [DataTypes::Byte,      :'cookie (random byte)'],
        [DataTypes::Byte,      :'cookie (random byte)'],
        [DataTypes::Byte,      :'cookie (random byte)'],
        [DataTypes::Byte,      :'cookie (random byte)'],
        [DataTypes::Byte,      :'cookie (random byte)'],
        [DataTypes::Byte,      :'cookie (random byte)'],
        [DataTypes::Byte,      :'cookie (random byte)'],
        [DataTypes::Byte,      :'cookie (random byte)'],
        [DataTypes::Byte,      :'cookie (random byte)'],
        [DataTypes::NameList,  :'kex_algorithms'],
        [DataTypes::NameList,  :'server_host_key_algorithms'],
        [DataTypes::NameList,  :'encryption_algorithms_client_to_server'],
        [DataTypes::NameList,  :'encryption_algorithms_server_to_client'],
        [DataTypes::NameList,  :'mac_algorithms_client_to_server'],
        [DataTypes::NameList,  :'mac_algorithms_server_to_client'],
        [DataTypes::NameList,  :'compression_algorithms_client_to_server'],
        [DataTypes::NameList,  :'compression_algorithms_server_to_client'],
        [DataTypes::NameList,  :'languages_client_to_server'],
        [DataTypes::NameList,  :'languages_server_to_client'],
        [DataTypes::Boolean,   :'first_kex_packet_follows'],
        [DataTypes::Uint32,    :'0 (reserved for future extension)'],
      ]
    end
  end
end
