# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class Authentication
    module Constant
      SERVICE_NAME = 'ssh-userauth'

      SUCCESS         = :success
      PARTIAL_SUCCESS = :partial_success
      FAILURE         = :failure
    end
  end
end
