# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  module SubclassWithoutPreferenceListable
    def inherited klass
      @subclass_list.push klass if @subclass_list
    end

    def [] key
      __subclass_list__(__method__).find{ |klass| klass::NAME == key }
    end

    def list_supported
      __subclass_list__(__method__).map{ |klass| klass::NAME }
    end

    def __subclass_list__ method_name
      send(:method_missing, method_name) unless @subclass_list
      @subclass_list
    end

    private :__subclass_list__
  end
end
