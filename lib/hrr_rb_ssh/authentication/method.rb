# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/subclass_with_preference_listable'

module HrrRbSsh
  class Authentication
    class Method
      @subclass_list = Array.new
      class << self
        include SubclassWithPreferenceListable
      end
    end
  end
end

require 'hrr_rb_ssh/authentication/method/none'
require 'hrr_rb_ssh/authentication/method/password'
require 'hrr_rb_ssh/authentication/method/publickey'
require 'hrr_rb_ssh/authentication/method/keyboard_interactive'
