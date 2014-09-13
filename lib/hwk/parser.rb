#!/usr/bin/ruby 
#-rtracer
#
#

require 'date'
require 'hwk'
require 'hwk/question'
require 'hwk/section'

module Hwk

  class Parser
    attr_accessor :hwk
    attr_accessor :directory
    attr_accessor :files
    [:title, :due_date,:class_name, :class_time, :class_professor, :author_name, :code_inclusion_configuration, :bibliographystyle].each do |m|
      self.class_eval( %Q\
        def #{m}(param=nil,&block)
           param.nil?  ? (return @#{m}) : (@#{m} = param)
           (instance_eval &block) if block_given?
        end
                      \ )

      def initialize
        @debug = false
        @title = "No title Set"
        @due_date = Date.new
        @class_name = "No class_name Set"
        @class_time = "No class_time Set"
        @class_professor = "No class_professor Set"
        @author_name = "No author_name Set"
        @code_inclusion_configuration = "% no code"
        @bibliographystyle = "plain"

        @identifier = { :prefix => 'HWK_', :suffix => '_HWK' }
        @ident_substr = @identifier[:prefix].length..(-1*(@identifier[:suffix].length+1))
        @ident_regex = /#{@identifier[:prefix]}\S+#{@identifier[:suffix]}/

         @questions = []
        @languages = []
        @biblio = []

        @hwk_dir = "~/Dropbox/Maths/latex/hwk/"
        @hwk_lang_dir = "snips/"
      end #initilize

      def method_missing( method, *args, &code )
        puts "missing: #{method}"
        super
      end

      def load_dsl( dsl )
        dsl_file = File.open(dsl,"rb")
        dsl_contents = dsl_file.read
        dsl_file.close
        instance_eval( dsl_contents )
      end

      def question( q, &block )
        @questions << Question.new( q, &block )
      end

      def section( s, &block )
        @questions << Section.new( s, &block )
      end

      def parse_to_tex( hwk_dsl_file )
        puts "parse_to_tex nothing!"
      end

      def include_bibliography( hwk_bib )
        @biblio << File.basename( hwk_bib, File.extname( hwk_bib ) )
      end

      def bibliography?
        @biblio.length > 0
      end

      def biblio_config
        bib_config = []
        # currently does get passed in multiple bib's, but can
        # once that is changed in include_bibliography
        @biblio.each do |bib|
          bib_config << '\bibliography{' + bib + '}'
        end

        bib_config
      end

      def include_language( lang )
        if (@languages.include? lang) == false
          @languages << lang
        end
      end

      def include_source( file, desc='' )
        @lang_suff = File.extname( file )[1..-1]
        source_text = ""

        if ( @lang_suff )
          include_language( @lang_suff )
        else
          $stderr.puts "Warning, unable to determine file type of '#{file}', no extension"
        end


        source_text = "\\#{@lang_suff}script{#{File.basename( file, File.extname( file ) )}}{#{desc}}"

        source_text
      end #include_source

      def language_configs
        language_config_block = []

        @languages.each do |lang|
          File.open( File.expand_path( @hwk_dir + @hwk_lang_dir + lang + ".snip" ) ).each do |line|
            language_config_block << line
          end
        end

        language_config_block
      end #language_configs

      def add_problem( problem )
        @problems << problem
      end

      def resolve_call( c )
        begin
          v = eval( c )
          if ( v.is_a?(String) )
            v = escape_string_for_latex( v )
          elsif ( v.is_a?(Array) )
            vs = ""
            v.each do |e|
              vs << e.to_s
            end
            v = vs
          elsif v.is_a?(Date)
            v = v.strftime("%a, %e %b %Y %l:%M %P")
          end
        rescue NoMethodError => nme
          v = "Unknown reference: " + c + "\n\t" + nme.to_s
        rescue TypeError => te
          abort( "TypeError at "+ te.backtrace[0].split(':')[0..1].join(':') + " call:" + c + "\n\t" + te.to_s)
        rescue NameError => ne
          abort( "NameError at "+ ne.backtrace[0].split(':')[0..1].join(':') + " call:" + c + "\n\t" + ne.to_s )
        end
        v
      end #resolve_call

      def escape_string_for_latex( s )
        if s.is_a?(String)
          s.gsub(/([&$#_{}~^])/, '\\\\\1')
        elsif s == nil
          ""
        else
          s
        end
      end # escape_string_for_latex

      def questions_loop
        question_block = []

        @questions.each do |q|
          question_block << q
        end

        question_block
      end # questions_loop

      def parse_template( template )
        tex_output = ""
        File.open( File.expand_path( template ) ).each do |line|
          if @debug then print "read: #{line}" end
          subs = line.scan(@ident_regex)
          if subs then
            if @debug then puts " found: #{subs}" end
            subs.each do |c|
              call = c[@ident_substr].downcase
              value = resolve_call( call )
              line = line.gsub(/#{c}/, value )
            end
          end
          if @debug then print line end
          tex_output << line
        end
        tex_output
      end # parse_template

    end 
  end # class HwkParser
end # module Hwk