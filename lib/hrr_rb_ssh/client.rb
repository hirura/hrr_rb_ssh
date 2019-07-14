# coding: utf-8
# vim: et ts=2 sw=2

require 'socket'
require 'stringio'
require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/mode'
require 'hrr_rb_ssh/transport'
require 'hrr_rb_ssh/authentication'
require 'hrr_rb_ssh/connection'

module HrrRbSsh
  class Client
    def self.start address, options={}
      client = self.new address, options
      client.start
      if block_given?
        begin
          yield client
        ensure
          client.close unless client.closed?
        end
      else
        client
      end
    end

    def initialize address, tmp_options={}
      @logger = Logger.new self.class.name
      @closed = true
      options = initialize_options tmp_options
      io = TCPSocket.new address, options['port']
      transport      = HrrRbSsh::Transport.new      io, HrrRbSsh::Mode::CLIENT, options
      authentication = HrrRbSsh::Authentication.new transport, HrrRbSsh::Mode::CLIENT, options
      @connection    = HrrRbSsh::Connection.new     authentication, HrrRbSsh::Mode::CLIENT, options
    end

    def initialize_options tmp_options
      tmp_options = Hash[tmp_options.map{|k, v| [k.to_s, v]}]
      options = {}
      options['port'] = tmp_options['port'] || 22
      options['username'] = tmp_options['username']
      options['authentication_preferred_authentication_methods'] = tmp_options['authentication_preferred_authentication_methods']
      options['client_authentication_password']             = tmp_options['password']
      options['client_authentication_publickey']            = tmp_options['publickey']
      options['client_authentication_keyboard_interactive'] = tmp_options['keyboard_interactive']
      options['transport_preferred_encryption_algorithms']      = tmp_options['transport_preferred_encryption_algorithms']
      options['transport_preferred_server_host_key_algorithms'] = tmp_options['transport_preferred_server_host_key_algorithms']
      options['transport_preferred_kex_algorithms']             = tmp_options['transport_preferred_kex_algorithms']
      options['transport_preferred_mac_algorithms']             = tmp_options['transport_preferred_mac_algorithms']
      options['transport_preferred_compression_algorithms']     = tmp_options['transport_preferred_compression_algorithms']
      options
    end

    def start
      @connection.start foreground: false
      @closed = false
    end

    def loop
      @connection.loop
    end

    def closed?
      @closed
    end

    def close
      @logger.debug { "closing client" }
      @closed = true
      @connection.close
      @logger.debug { "client closed" }
    end

    def exec! command, pty: false, env: {}
      @logger.debug { "start exec!: #{command}" }
      out_buf = StringIO.new
      err_buf = StringIO.new
      begin
        @logger.info { "Opning channel" }
        channel = @connection.request_channel_open "session"
        @logger.info { "Channel opened" }
        if pty
          channel.send_channel_request_pty_req 'xterm', 80, 24, 580, 336, ''
        end
        env.each{ |variable_name, variable_value|
          channel.send_channel_request_env variable_name, variable_value
        }
        channel.send_channel_request_exec command
        out_t = Thread.new {
          while true
            begin
              out_buf.write channel.io[1].readpartial(10240)
            rescue
              break
            end
          end
        }
        err_t = Thread.new {
          while true
            begin
              err_buf.write channel.io[2].readpartial(10240)
            rescue
              break
            end
          end
        }
        [out_t, err_t].each{ |t|
          begin
            t.join
          rescue => e
            @logger.warn { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
          end
        }
      rescue => e
        @logger.error { "Failed opening channel" }
        @logger.error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
        raise "Error in exec!"
      ensure
        if channel
          @logger.info { "closing channel IOs" }
          channel.io.each{ |io| io.close rescue nil }
          @logger.info { "channel IOs closed" }
          @logger.info { "closing channel" }
          @logger.info { "wait until threads closed in channel" }
          channel.wait_until_closed
          channel.close
          @logger.info { "channel closed" }
        end
      end
      [out_buf.string, err_buf.string]
    end

    def exec command, pty: false, env: {}
      @logger.debug { "start exec: #{command}" }
      begin
        @logger.info { "Opning channel" }
        channel = @connection.request_channel_open "session"
        @logger.info { "Channel opened" }
        if pty
          channel.send_channel_request_pty_req 'xterm', 80, 24, 580, 336, ''
        end
        env.each{ |variable_name, variable_value|
          channel.send_channel_request_env variable_name, variable_value
        }
        channel.send_channel_request_exec command
        yield channel.io
      rescue => e
        @logger.error { "Failed opening channel" }
        @logger.error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
        raise "Error in shell"
      ensure
        if channel
          @logger.info { "closing channel IOs" }
          channel.io.each{ |io| io.close rescue nil }
          @logger.info { "channel IOs closed" }
          @logger.info { "closing channel" }
          @logger.info { "wait until threads closed in channel" }
          channel.wait_until_closed
          channel.close
          @logger.info { "channel closed" }
        end
      end
      channel_exit_status = channel.exit_status rescue nil
    end

    def shell env: {}
      @logger.debug { "start shell" }
      begin
        @logger.info { "Opning channel" }
        channel = @connection.request_channel_open "session"
        @logger.info { "Channel opened" }
        channel.send_channel_request_pty_req 'xterm', 80, 24, 580, 336, ''
        env.each{ |variable_name, variable_value|
          channel.send_channel_request_env variable_name, variable_value
        }
        channel.send_channel_request_shell
        yield channel.io
      rescue => e
        @logger.error { "Failed opening channel" }
        @logger.error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
        raise "Error in shell"
      ensure
        if channel
          @logger.info { "closing channel IOs" }
          channel.io.each{ |io| io.close rescue nil }
          @logger.info { "channel IOs closed" }
          @logger.info { "closing channel" }
          @logger.info { "wait until threads closed in channel" }
          channel.wait_until_closed
          channel.close
          @logger.info { "channel closed" }
        end
      end
      channel_exit_status = channel.exit_status rescue nil
    end
  end
end
