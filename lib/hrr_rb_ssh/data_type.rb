# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  # DataType is a parent class of classes that provide methods to convert value and binary string each other.
  class DataType
  end
end

require 'hrr_rb_ssh/data_type/byte'
require 'hrr_rb_ssh/data_type/boolean'
require 'hrr_rb_ssh/data_type/uint32'
require 'hrr_rb_ssh/data_type/uint64'
require 'hrr_rb_ssh/data_type/string'
require 'hrr_rb_ssh/data_type/mpint'
require 'hrr_rb_ssh/data_type/name_list'
