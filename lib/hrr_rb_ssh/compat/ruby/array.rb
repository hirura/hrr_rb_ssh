# coding: utf-8
# vim: et ts=2 sw=2

if RUBY_VERSION < "2.1"
  class Array
    def to_h
      h = Hash.new
      self.each do |k, v|
        h[k] = v
      end
      h
    end
  end
end
