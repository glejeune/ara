require 'logger'
require 'singleton'

module Ara
   def self.logger
      return L.instance.logger
   end

   def self.logger=(l)
      L.instance.logger=l
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
