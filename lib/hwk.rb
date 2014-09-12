
#
#


require 'hwk/hwkfiles'
require 'hwk/parser'

module Hwk
  EXTNAME = 'hwk'
  TEMPLATE_DIR = "~/Dropbox/Maths/latex/hwk/tex/"
  TEMPLATE_FILE = "homework_template.tex"
  FQP_TEMPLATE_FILE = File.join(TEMPLATE_DIR,TEMPLATE_FILE)
  NEW_HWK_FILE  = "template.hwk"

  class Homework
    attr_reader :parser, :files
    attr_accessor :parsed_tex

    def initialize( directory )
      @files = HwkFiles.new( directory )
      @parser = Parser.new
      @tex = nil
    end

    def load
      @parser.load_dsl files.dsl
      @parsed_tex = @parser.parse_template( FQP_TEMPLATE_FILE )
    end

    def write_tex
      output_file = File.open( @files.tex, "w" )
      output_file.write( @parsed_tex )
      output_file.close
    end
      

  end

end
