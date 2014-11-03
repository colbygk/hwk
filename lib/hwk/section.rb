
# yoinked from: http://raycodingdotnet.wordpress.com/2013/08/11/writing-domain-specific-langaugedsl-in-ruby-day-1/

require 'hwk/includable'

module Hwk

  class Section < Includable
    attr_accessor :im_a_part
    [:prefix, :suffix, :enumstyle, :title, :text,:solution, :parts].each do |m|
      self.class_eval( %Q\
        def #{m}(*param,&block)
           param.nil?  ? (return @#{m}) : (@#{m} = param.join )
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

      def to_s
        if @im_a_part == 'part'
          to_s_part_section
        else
          to_s_base_section
        end
      end

      def to_s_part_section
        section_str = @prefix.to_s << '\item '
        section_str << text.to_s << "\n\\par\n"

        if ( solution.to_s.length > 0 )
          section_str << '\subSection{' << '\setlength\parindent{1em} \hangindent=1em' << solution.to_s << "}\n"
        end

        if ( @parts && @parts.length > 0 )
          section_str << '\begin{enumerate}[label=' <<  @enumstyle << ']'
          @parts.each do |p|
            section_str << p.to_s << "\n"
          end
          section_str << '\end{enumerate}' << "\n"
        end

       section_str << @suffix.to_s
      end

      def to_s_base_section
        section_str = @prefix.to_s << '\begin{homeworkSection}'<< ((@title&&@title.length>0) ? "[#{@title}]" : '') << "\n"
        section_str << @text.to_s << "\n\\par\n"

        if ( @solution.to_s.length > 0 )
          section_str << '\subSection{' << '\setlength\parindent{1em} \hangindent=1em' << solution.to_s << "}\n"
        end

        if ( @parts && @parts.length > 0 )
          section_str << '\begin{enumerate}[label=' << @enumstyle << ']' << "\n"
          @parts.each do |p|
            section_str << p.to_s << "\n"
          end
          section_str << '\end{enumerate}' << "\n"
        end

        section_str << '\end{homeworkSection}' << "\n" 
        section_str << @suffix.to_s
      end
    end
  end

end
