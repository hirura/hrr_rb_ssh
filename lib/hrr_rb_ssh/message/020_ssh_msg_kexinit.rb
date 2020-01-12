# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Message
    class SSH_MSG_KEXINIT
      include Codable

      ID    = self.name.split('::').last
      VALUE = 20

      DEFINITION = [
        #[DataType, Field Name]
        [DataType::Byte,      :'message number'],
        [DataType::Byte,      :'cookie (random byte)'],
        [DataType::Byte,      :'cookie (random byte)'],
        [DataType::Byte,      :'cookie (random byte)'],
        [DataType::Byte,      :'cookie (random byte)'],
        [DataType::Byte,      :'cookie (random byte)'],
        [DataType::Byte,      :'cookie (random byte)'],
        [DataType::Byte,      :'cookie (random byte)'],
        [DataType::Byte,      :'cookie (random byte)'],
        [DataType::Byte,      :'cookie (random byte)'],
        [DataType::Byte,      :'cookie (random byte)'],
        [DataType::Byte,      :'cookie (random byte)'],
        [DataType::Byte,      :'cookie (random byte)'],
        [DataType::Byte,      :'cookie (random byte)'],
        [DataType::Byte,      :'cookie (random byte)'],
        [DataType::Byte,      :'cookie (random byte)'],
        [DataType::Byte,      :'cookie (random byte)'],
        [DataType::NameList,  :'kex_algorithms'],
        [DataType::NameList,  :'server_host_key_algorithms'],
        [DataType::NameList,  :'encryption_algorithms_client_to_server'],
        [DataType::NameList,  :'encryption_algorithms_server_to_client'],
        [DataType::NameList,  :'mac_algorithms_client_to_server'],
        [DataType::NameList,  :'mac_algorithms_server_to_client'],
        [DataType::NameList,  :'compression_algorithms_client_to_server'],
        [DataType::NameList,  :'compression_algorithms_server_to_client'],
        [DataType::NameList,  :'languages_client_to_server'],
        [DataType::NameList,  :'languages_server_to_client'],
        [DataType::Boolean,   :'first_kex_packet_follows'],
        [DataType::Uint32,    :'0 (reserved for future extension)'],
      ]
    end
  end
end
