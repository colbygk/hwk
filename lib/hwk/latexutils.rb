
module Hwk
  class Latexutils
    def self.make_generic_table( tbegin, tend, align, hline, text_block )
      lines = []
      text_block.split("\n").each do |l|
        parsed = l.gsub(/\s+/m, ' ').strip.split(' ')
        if parsed.length > 0
          if lines[-1].nil? == false && lines[-1].length != 0 && lines[-1].length != parsed.length 
            abort( "Columns mismatch when creating table" )
          end
          lines << parsed
        end
      end

      cols = '{' + align*lines[-1].length + '}'
      table_text = [ tbegin[0] + cols ]
      k = 0
      lines.each do |l|
       table_text << hline unless (k != 1)
       suffix = ''
       suffix = '\\\\\\' unless (k == lines.length)
       table_text << (l.join(' & ') + suffix).gsub(/_/, '\_')
       k += 1
      end
      table_text << tend

      table_text.join("\n")
    end

    def self.make_table( size='\\small', align='r', hline='\hline', text_block )
      table_tbegin = [" \\begin{center}#{size}\\begin{tabular}"]
      table_tend = ' \end{tabular}\end{center} '
      make_generic_table( table_tbegin, table_tend, align, hline, text_block )
    end

    def self.make_ax_b( a, x, b )
      make_array( 'r', '', '\left(', '\right)', a ) + x + '=' +
        make_array( 'r', '', '\left(', '\right)', b )
    end

    def self.make_array( align='r', hline='', left, right, text_block )
      table_tbegin = [" #{left} \\begin{array}"]
      table_tend = " \\end{array} #{right}"
      make_generic_table( table_tbegin, table_tend, align, hline, text_block )
    end

    def self.itemize( *q )
     s = '\begin{itemize}'
     q.each do |i|
       s << '\item ' << i
     end
     s << '\end{itemize}'
    end

  end
end
