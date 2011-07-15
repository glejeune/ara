require 'logger'
require 'singleton'

module Ara
   def self.logger
      return L.instance.logger
   end

   def self.logger=(l)
      L.instance.logger=l
   end

   def self.method_missing(method_sym, *arguments, &block)
      if self.logger.respond_to?(method_sym)
         self.logger.send(method_sym, *arguments)
      else
         raise NoMethodError, "undefined method `#{method_sym.to_s}' for Ara:Module"
      end
   end

   class L #:nodoc:
      include Singleton

      def initialize
         @mutex = Mutex.new
         @logger = Logger.new STDERR
      end

      def logger
         @mutex.synchronize { @logger }
      end

      def logger=(l)
         @mutex.synchronize { @logger=l }
      end
   end
end
