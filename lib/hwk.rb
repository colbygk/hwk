
#
#


require 'tempfile'

require 'hwk/hwkfiles'
require 'hwk/parser'

module Hwk
  VERSION = '0.0.4'
  EXTNAME = 'hwk'
  HWK_DIR = "~/Dropbox/Maths/latex/hwk/"
  TEMPLATE_DIR = HWK_DIR + "tex/"
  TEMPLATE_FILE = "homework_template.tex"
  FQP_TEMPLATE_FILE = File.join(TEMPLATE_DIR,TEMPLATE_FILE)
  NEW_HWK_FILE  = "template.hwk"

  class Homework
    attr_reader :parser, :files
    attr_accessor :parsed_tex, :tex_trace

    def initialize( directory )
      @files = HwkFiles.new( directory )
      @parser = Parser.new
      @tex = nil
    end

    def load
      @parser.load_dsl files.dsl
      @parsed_tex,@tex_trace = @parser.parse_template( FQP_TEMPLATE_FILE )
    end

    def write_tex
      # Make sure that latexmk (if running) doesn't catch the tex file in midconstruction...
      #output_file = File.open( @files.tex, "w" )

      output_file = Tempfile.new( "#{@files.tex.basename}" )
      output_file.write( @parsed_tex )
      output_file.close
      File.rename( output_file.path, @files.tex.basename )
    end
      
    def write_tex_trace
      l = 1
      @tex_trace.each { |t|
        puts "#{l}: #{t}"
        l += 1
      }
    end

  end

end
