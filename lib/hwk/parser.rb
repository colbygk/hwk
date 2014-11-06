#!/usr/bin/ruby 
#-rtracer
#
#

require 'date'
require 'hwk'
require 'hwk/question'
require 'hwk/section'
require 'hwk/latexutils'
require 'hwk/hwktracer'

module Hwk

  class Parser
    LU = Hwk::Latexutils  # allows access to Latexutils as LU in hwk file

    attr_accessor :hwk
    attr_accessor :directory
    attr_accessor :files

    [:title, :header_configs, :due_date,:class_name, :class_time,   \
     :class_professor, :author_name, :code_inclusion_configuration, \
     :bibliographystyle].each do |m|
      self.class_eval( %Q\
        def #{m}(param=nil,&block)

           if param.nil? 
             return @#{m}, HWKTRACE.lines[self.object_id]['#{m}']
           else
             HWKTRACE.update( obj: self, name: '#{m}', line_info: caller(0)[1], value: param )
             @#{m} = param
           end

           (instance_eval &block) if block_given?
        end
                         \ )

      def initialize
        @debug = false
        @title = "No title Set"
        @header_configs = ""
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

        @sections = []
        @languages = []
        @biblio = []

        @hwk_dir = ENV['HWK_DIR']
        @hwk_lang_dir = "/snips/"
      end #initilize

      def method_missing( method, *args, &code )
        puts "missing: #{method}"
        super
      end

      def to_sym
        return :Parser
      end

      def load_dsl( dsl )
        dsl_file = File.open(dsl,"rb")
        dsl_contents = dsl_file.read
        dsl_file.close

        # the following allows for placing a block start
        # on the line following a method/whatever expecting a block
        # e.g.
        #   question
        #   do
        #   end
        # vs
        #   question do
        #   end
        # or
        #   question
        #   {
        #   }
        # vs
        #   question {
        #   }
        #   
        # This also applies to section
        #
        #collapsed_dsl_contents = dsl_contents.gsub(/\n\s?do/, " \\ \ndo")
        #collapsed_dsl_contents = collapsed_dsl_contents.gsub(/\n\s?{/, " \\ \n{")
        # deprecated for now...
        collapsed_dsl_contents = dsl_contents
        begin
          instance_eval( collapsed_dsl_contents, dsl )
        rescue Exception => e
          full_trace = e.backtrace
          full_trace.map! { |s|
            as = s.split(':')
            if ( as[0].include? dsl )
              tab = "  "
            else
              tab = "\t"
            end
            as[0] = tab + File.split(s)[1]
            as.join(':')
          }
          abort("\n  "+ File.basename(e.to_s) + "\n\n  trace:\n" + full_trace.join("\n"))
        end
      end

      def question( *q, &block )
        @sections << Question.new( *q, &block )
      end

      def section( *s, &block )
        @sections << Section.new( *s, &block )
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

      def language_configs
        begin
          language_config_block = []
          @sections.each do |s|
            s.languages.each do |l|
              @languages << l unless @languages.include? l
            end
          end

          @languages.each do |lang|
            file_name = File.expand_path( @hwk_dir + @hwk_lang_dir + lang + ".snip" )
            File.open( file_name ).each do |line|
              language_config_block << line
            end
          end
        rescue Exception => e
          puts( e.to_s + "\n\n\t" + e.backtrace.join("\n\t") )
        end


        language_config_block
      end #language_configs

      def add_problem( problem )
        @problems << problem
      end

      def resolve_call( c )

        begin
          v, t = eval( c )
          if ( v.is_a?(String) )
            v = escape_string_for_latex( v )  # may not need this?
          elsif ( v.is_a?(Array) )
            vss = ''
            ts = nil
            v.each do |e|
              vs, ts = e.to_traced_s
              vss << vs
              t.concat(ts) unless ts.nil?
            end
            v = vss
          elsif v.is_a?(Date)
            v = v.strftime("%a, %e %b %Y %l:%M %P")
          end
        rescue NoMethodError => nme
          v = "Unknown reference: " + c + "\n\t" + nme.to_s
          abort( v + nme.backtrace.join("\n\t"))
        rescue TypeError => te
          abort( "TypeError at "+ te.backtrace[0].split(':')[0..1].join(':') + " call:" + c + "\n\t" + te.to_s)
        rescue NameError => ne
          abort( "NameError at "+ ne.backtrace[0].split(':')[0..1].join(':') + " call:" + c + "\n\t" + ne.to_s )
        end

        return v, t

      end #resolve_call

      def escape_string_for_latex( s )
        if s.is_a?(String)
          s.gsub(/([&$#_~^])/, '\\\\\1')
        elsif s == nil
          ""
        else
          s
        end
      end # escape_string_for_latex

      def sections_loop
        sections_block = []

        @sections.each do |s|
          sections_block << s
        end

        return sections_block, []
      end # sections_loop

      def parse_template( template )
        tex_output = ""
        template_tex_lines = 0
        tex_trace = []
        trace_elements = nil

        fq_template = File.expand_path( template )

        File.open( fq_template ).each do |line|
          if @debug then print "read: #{line}" end
          subs = line.scan(@ident_regex)
          if subs.length > 0 then
            if @debug then puts " found: #{subs}" end
            subs.each do |c|
              call = c[@ident_substr].downcase
              value, trace_elements = resolve_call( call )
              if line.strip.length == c.length
                # These are sections/questions/larger substitutions
                line = value
              else
                # These are a straight substitution
                line = line.sub(/#{c}/, value )
              end # if line.strip.length == c.length
            end # subs.each do

            unless trace_elements.nil?
              if trace_elements.is_a?(Hwkline)
                tex_trace << trace_elements.hwk_line
              elsif trace_elements.is_a?(Array)
                trace_elements.each { |t|
                  tex_trace << t
                }
              else
                tex_trace << "unknown:0:voodoo"
              end
            end
          else # if subs
            line.lines.each do |l|
              tex_trace << "#{fq_template}:#{template_tex_lines}:from template"
              template_tex_lines += 1
            end

          end # if subs
          if @debug then print line end

          tex_output << line unless line.nil?

        end # File.open

        # HWKTRACE.dump

        return tex_output, tex_trace
      end # parse_template

    end 
  end # class HwkParser
end # module Hwk
