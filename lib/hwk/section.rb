
# yoinked from: http://raycodingdotnet.wordpress.com/2013/08/11/writing-domain-specific-langaugedsl-in-ruby-day-1/


module Hwk

  class Section
    attr_accessor :im_a_part
    [:enumstyle, :section_title, :text,:solution, :parts].each do |m|
      self.class_eval( %Q\
        def #{m}(param=nil,&block)
           param.nil?  ? (return @#{m}) : (@#{m} = param)
           (instance_eval &block) if block_given?
        end
                      \ )

      def initialize( s, &block )
        @enumstyle = '\alph'
        @im_a_part = nil
        call_stack = caller(2)
        if call_stack
          @im_a_part = call_stack[0].scan(/`(\S+)'/)[0][0]
        end

        @text = s
        @parts = []
        (block.arity < 1 ?  (instance_eval &block) : block.call(self)) if block_given?
      end

      def part( s, &block )
        @parts << Section.new( s, &block )
      end

      def to_s
        if @im_a_part == 'part'
          to_s_part_section
        else
          to_s_base_section
        end
      end

      def to_s_part_section
        section_str = '\item '
        section_str << text.to_s << "\n\\par\n"

        if ( solution.to_s.length > 0 )
          section_str << '\subSection{' << '\setlength\parindent{1em} \hangindent=1em' << solution.to_s << "}\n"
        end

        if ( @parts && @parts.length > 0 )
          section_str << '\begin{enumerate}[label=(' <<  enumstyle << '*)]'
          @parts.each do |p|
            section_str << p.to_s << "\n"
          end
          section_str << '\end{enumerate}' << "\n"
        end

       section_str
      end

      def to_s_base_section
        section_str = '\begin{homeworkSection}' << "\n"
        section_str << text.to_s << "\n\\par\n"

        if ( @solution.to_s.length > 0 )
          section_str << '\subSection{' << '\setlength\parindent{1em} \hangindent=1em' << solution.to_s << "}\n"
        end

        if ( @parts && @parts.length > 0 )
          section_str << '\begin{enumerate}[label=(' << enumstyle << '*)]' << "\n"
          @parts.each do |p|
            section_str << p.to_s << "\n"
          end
          section_str << '\end{enumerate}' << "\n"
        end

        section_str << '\end{homeworkSection}' << "\n" 
        section_str
      end
    end
  end

end
