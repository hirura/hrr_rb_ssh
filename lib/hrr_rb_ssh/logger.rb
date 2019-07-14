# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class Logger
    @@logger = nil

    class << self
      def initialize logger
        @@logger = logger
      end

      def uninitialize
        @@logger = nil
      end

      def initialized?
        @@logger != nil
      end
    end

    def initialize name
      @name = name
    end

    def fatal
      if @@logger
        @@logger.fatal { "p#{Process.pid}.t#{Thread.current.object_id}: #{@name}: #{yield}" }
      end
    end

    def error
      if @@logger
        @@logger.error { "p#{Process.pid}.t#{Thread.current.object_id}: #{@name}: #{yield}" }
      end
    end

    def warn
      if @@logger
        @@logger.warn { "p#{Process.pid}.t#{Thread.current.object_id}: #{@name}: #{yield}" }
      end
    end

    def info
      if @@logger
        @@logger.info { "p#{Process.pid}.t#{Thread.current.object_id}: #{@name}: #{yield}" }
      end
    end

    def debug
      if @@logger
        @@logger.debug { "p#{Process.pid}.t#{Thread.current.object_id}: #{@name}: #{yield}" }
      end
    end
  end
end
