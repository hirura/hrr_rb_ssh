# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class Logger
    @@logger = nil

    def self.initialize logger
      @@logger = logger
    end

    def self.uninitialize
      @@logger = nil
    end

    def self.initialized?
      @@logger != nil
    end

    def initialize name
      @name = name
    end

    def fatal message
      if self.class.initialized?
        @@logger.fatal "#{@name}: #{message}"
      end
    end

    def error message
      if self.class.initialized?
        @@logger.error "#{@name}: #{message}"
      end
    end

    def warn message
      if self.class.initialized?
        @@logger.warn "#{@name}: #{message}"
      end
    end

    def info message
      if self.class.initialized?
        @@logger.info "#{@name}: #{message}"
      end
    end

    def debug message
      if self.class.initialized?
        @@logger.debug "#{@name}: #{message}"
      end
    end
  end
end
