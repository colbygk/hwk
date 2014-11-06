
# yoinked from: http://raycodingdotnet.wordpress.com/2013/08/11/writing-domain-specific-langaugedsl-in-ruby-day-1/

require 'hwk/includable'
require 'hwk/hwktracer'

module Hwk

  class Section < Includable
    attr_accessor :im_a_part
    [:prefix, :suffix, :enumstyle, :title, :text,:solution, :parts].each do |m|
      self.class_eval( %Q\
        def #{m}(*param,&block)

           if param.nil?
             return @#{m}, HWKTRACE.lines[self.object_id]['#{m}']
           else
             HWKTRACE.update( obj: self, name: '#{m}', line_info: caller(0)[1], value: param )
             @#{m} = param.join
           end

           (instance_eval &block) if block_given?
        end
                      \ )

      def initialize( *s, &block )
        super(s,&block)

        @prefix = ''
        @enumstyle = '\alph'
        @im_a_part = nil
        call_stack = caller(2)
        if call_stack
          @im_a_part = call_stack[0].scan(/`(\S+)'/)[0][0]
        end

        @title = s[0] unless s.nil?
        @text = s[1..-1].join unless s[1..-1].nil?
        @parts = []
        (block.arity < 1 ?  (instance_eval &block) : block.call(self)) if block_given?
      end

      def newpage( *s, &block )
        @prefix = '\newpage '
      end

      def part( *s, &block )
        @parts << Section.new( *s, &block )
      end

      def to_traced_s
        if @im_a_part == 'part'
          to_s_part_section
        else
          to_s_base_section
        end
      end

      def to_s_part_section
        section_str = ''
        trace_lines = []

        section_str << add_and_trace_from( add_str: @prefix.to_s << '\item ', tr: trace_lines, name: 'prefix' )
        section_str << add_and_trace_from( add_str: @text.to_s << "\n\\par\n", tr: trace_lines, name: 'text' )

        if ( @solution.to_s.length > 0 )
          section_str << add_and_trace_from( add_str: '\subSection{' << '\setlength\parindent{1em} \hangindent=1em' \
                            << @solution.to_s << "}\n", tr: trace_lines, name: 'solution' )
        end

        if ( @parts && @parts.length > 0 )
          section_str << add_and_trace_from( add_str: '\begin{enumerate}[label=' <<  @enumstyle << ']', tr: trace_lines,
                                             name: 'enumstyle' )
          @parts.each do |p|
            s_str, s_tr = p.to_traced_s
            section_str << s_str
            s_tr.each do |str|
              trace_lines << str
            end
          end

          section_str << add_and_trace_from( add_str: '\end{enumerate}' << "\n", tr: trace_lines )
        end

        section_str << add_and_trace_from( add_str: @suffix.to_s, tr: trace_lines, name: 'suffix' )

        return section_str, trace_lines
      end


      def to_s_base_section
        section_str = ''
        trace_lines = []
       
        section_str = add_and_trace_from( add_str: @prefix.to_s << '\begin{homeworkSection}' \
                << ((@title&&@title.length>0) ? "[#{@title}]" : '') << "\n", tr: trace_lines, name: 'prefix' )
        section_str << add_and_trace_from( add_str: @text.to_s << "\n\\par\n", tr: trace_lines, name: 'text' )

        if ( @solution.to_s.length > 0 )
          section_str << add_and_trace_from( add_str: '\subSection{' << '\setlength\parindent{1em} \hangindent=1em' \
                    << @solution.to_s << "}\n", tr: trace_lines, name: 'solution' )
        end

        if ( @parts && @parts.length > 0 )
          section_str << add_and_trace_from( add_str: '\begin{enumerate}[label=' << @enumstyle << ']' << "\n",
              tr: trace_lines, name: 'enumstyle' )

          @parts.each do |p|
            s_str, s_tr = p.to_traced_s
            section_str << s_str
            s_tr.each do |str|
              trace_lines << str
            end
          end

          section_str << add_and_trace_from( add_str: '\end{enumerate}' << "\n", tr: trace_lines )
        end

        section_str << add_and_trace_from( add_str: '\end{homeworkSection}' << "\n" , tr: trace_lines )
        section_str << add_and_trace_from( add_str: @suffix.to_s, tr: trace_lines, name: 'suffix' )

        return section_str, trace_lines
      end

    end
  end

end
