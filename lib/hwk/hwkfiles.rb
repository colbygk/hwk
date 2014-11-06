
require 'hwk'

module Hwk

  class HwkFiles

    attr_reader :directory, :dsl, :tex, :pdf, :aux, :bbl

    class HwkFileString < String
      attr_accessor :exists

      def initialize( val )
        @exists = false
        super val
      end

      def exists?
        File.exists?( self )
      end

      def basename
        File.basename( self )
      end

      def mtime
        File.stat( self ).mtime
      end
      
      def wait_for_modification
        if exists?
          modified = false
          t = self.mtime

          while ( modified == false )
            modified = true unless t == self.mtime
            sleep(1)
          end

        end
      end

    end

    def initialize( here )
      @directory = here
      locate_likely_hwk_files( @directory )
    end

    def locate_likely_hwk_files( directory )
      @dsl = nil
      @tex = nil
      @pdf = nil
      @aux = nil
      @bbl = nil

      directory = File.expand_path(directory)

      hwks = Dir.glob( File.join(directory,'*.'+EXTNAME) )
      hwks.each do |hwk|
        @dsl = HwkFileString.new( hwk )
      end
      if dsl
        @tex = HwkFileString.new( dsl.gsub(/\.#{EXTNAME}/,'.tex' ) )
        @pdf = HwkFileString.new(dsl.gsub(/\.#{EXTNAME}/,'.pdf' ) )
        @aux = HwkFileString.new(dsl.gsub(/\.#{EXTNAME}/,'.aux' ) )
        @bbl = HwkFileString.new(dsl.gsub(/\.#{EXTNAME}/,'.bbl' ) )
      end
    end


  end
end
