# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class Connection
    class Channel
      class ChannelType
        class Session
          module RequestType
            class RequestType
              @@list = Array.new

              def self.inherited klass
                @@list.push klass
              end

              def self.list
                @@list
              end

              def self.name_list
                @@list.map{ |klass| klass::NAME }
              end

              def self.[] key
                @@list.find{ |klass| key == klass::NAME }
              end
            end
          end
        end
      end
    end
  end
end
