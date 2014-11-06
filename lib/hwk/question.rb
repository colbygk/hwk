
# yoinked from: http://raycodingdotnet.wordpress.com/2013/08/11/writing-domain-specific-langaugedsl-in-ruby-day-1/

require 'hwk/includable'
require 'hwk/hwktracer'

module Hwk

  class Question < Includable
    attr_accessor :im_a_part
    attr_accessor :lines

    [:prefix, :suffix, :enumstyle, :text, :title, \
     :solution, :parts, :title_suffix].each do |m|
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

      def initialize( *q, &block )
        super(q,&block)

        @lines = {}
        @prefix = ''
        @enumstyle = '(\alph*)'
        @im_a_part = nil
        call_stack = caller(2)
        if call_stack
          @im_a_part = call_stack[0].scan(/`(\S+)'/)[0][0]
        end

        @title = nil
        if @im_a_part == 'part'
          @text = q[0..-1].join unless q[1..-1].nil?
        else
          @title = q[0] unless q.nil?
          @text = q[1..-1].join unless q[1..-1].nil?
        end
        @parts = []

        (block.arity < 1 ?  (instance_eval &block) : block.call(self)) if block_given?

      end

      def newpage( *q, &block )
        @prefix << '\newpage '
      end

      def to_sym
        if @im_a_part == 'part'
          return :QuestionPart
        else
          return :Question
        end
      end

      def part( *q, &block )
        @parts << Question.new( *q, &block )
      end

      def to_traced_s
        if @im_a_part == 'part'
          to_s_part_question
        else
          to_s_base_question
        end
      end

      def to_s_part_question
        question_str = ''
        trace_lines = []

        question_str << add_and_trace_from( add_str: @prefix.to_s << '\item ', tr: trace_lines, name: 'prefix' )
        question_str << add_and_trace_from( add_str: @text.to_s << "\n\\par\n", tr: trace_lines, name: 'text' )

        if ( @solution.to_s.length > 0 )
          question_str << add_and_trace_from( add_str: '\problemAnswer{' \
                 << '\setlength\parindent{1em} \hangindent=1em' \
                 << @solution.to_s << "}\n", tr: trace_lines, name: 'solution' )
        end

        if ( @parts && @parts.length > 0 )
          question_str << add_and_trace_from( add_str: '\begin{enumerate}[label=' \
              <<  @enumstyle << ']', tr: trace_lines, \
              name: 'enumstyle' )
          @parts.each do |p|
            p_str, p_tr = p.to_traced_s
            question_str << p_str
            p_tr.each do |ptr|
              trace_lines << ptr
            end
          end
          question_str << add_and_trace_from( add_str: '\end{enumerate}' << "\n", tr: trace_lines )
        end

       question_str << add_and_trace_from( add_str: @suffix.to_s, tr: trace_lines, name: 'suffix' )

       return question_str, trace_lines
      end

      def to_s_base_question
        trace_lines = []
        question_str = ''

        question_str << add_and_trace_from(  add_str: @prefix.to_s << "\n", tr: trace_lines, name: 'prefix', loc: caller(0)[0] )

        question_str << add_and_trace_from( add_str: '\begin{homeworkProblem}' << ((@title&&@title.length>0) ? "[#{@title}]" : '') << "\n", \
                                            tr: trace_lines, name: 'title', loc: caller(0)[0] )
#
        question_str << add_and_trace_from( add_str: @text.to_s << "\n\\par\n", tr: trace_lines, name: 'text', loc: caller(0)[0] )

        if ( @solution.to_s.length > 0 )
          question_str << add_and_trace_from( add_str: '\problemAnswer{' << '\setlength\parindent{1em} \hangindent=1em' << @solution.to_s << "}\n", \
                                              tr: trace_lines, name: 'solution', loc: caller(0)[0] )
        end

        if ( @parts && @parts.length > 0 )
          question_str << add_and_trace_from( add_str: '\begin{enumerate}[label=' << @enumstyle << ']' << "\n", \
               tr: trace_lines, name: 'enumstyle' )
          @parts.each do |p|
            p_str, p_tr = p.to_traced_s
            question_str << p_str
            p_tr.each do |ptr|
              trace_lines << ptr
            end
          end
          question_str << add_and_trace_from( add_str: '\end{enumerate}' << "\n", tr: trace_lines )
        end

        question_str << add_and_trace_from( add_str: '\end{homeworkProblem}' << "\n", tr: trace_lines )
        question_str << add_and_trace_from( add_str: @suffix.to_s, tr: trace_lines )

        return question_str, trace_lines
      end

    end

  end # class Question

end # module Hwk
