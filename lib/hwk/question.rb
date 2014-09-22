
# yoinked from: http://raycodingdotnet.wordpress.com/2013/08/11/writing-domain-specific-langaugedsl-in-ruby-day-1/

require 'hwk/includable'

module Hwk

  class Question < Includable
    attr_accessor :im_a_part
    [:prefix, :suffix, :enumstyle, :text, :title, :solution, :parts, :title_suffix].each do |m|
      self.class_eval( %Q\
        def #{m}(*param,&block)
           param.nil?  ? (return @#{m}) : (@#{m} = param.join)
           (instance_eval &block) if block_given?
        end
                      \ )

      def initialize( *q, &block )
        super(q,&block)

        @enumstyle = '\alph'
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

      def part( *q, &block )
        @parts << Question.new( *q, &block )
      end

      def to_s
        if @im_a_part == 'part'
          to_s_part_question
        else
          to_s_base_question
        end
      end

      def to_s_part_question
        question_str = @prefix.to_s << '\item '
        question_str << @text.to_s << "\n\\par\n"

        if ( @solution.to_s.length > 0 )
          question_str << '\problemAnswer{' << '\setlength\parindent{1em} \hangindent=1em' << @solution.to_s << "}\n"
        end

        if ( @parts && @parts.length > 0 )
          question_str << '\begin{enumerate}[label=(' <<  @enumstyle << '*)]'
          @parts.each do |p|
            question_str << p.to_s << "\n"
          end
          question_str << '\end{enumerate}' << "\n"
        end

       question_str << @suffix.to_s
      end

      def to_s_base_question
        question_str = @prefix.to_s << '\begin{homeworkProblem}' << ((@title&&@title.length>0) ? "[#{@title}]" : '') << "\n"
        #question_str = '\begin{homeworkProblem}' << "\n"
        question_str << @text.to_s << "\n\\par\n"

        if ( @solution.to_s.length > 0 )
          question_str << '\problemAnswer{' << '\setlength\parindent{1em} \hangindent=1em' << @solution.to_s << "}\n"
        end

        if ( @parts && @parts.length > 0 )
          question_str << '\begin{enumerate}[label=(' << @enumstyle << '*)]' << "\n"
          @parts.each do |p|
            question_str << p.to_s << "\n"
          end
          question_str << '\end{enumerate}' << "\n"
        end

        question_str << '\end{homeworkProblem}' << "\n" 
        question_str << @suffix.to_s
      end
    end
  end

end
