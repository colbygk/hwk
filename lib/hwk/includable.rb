
# yoinked from: http://raycodingdotnet.wordpress.com/2013/08/11/writing-domain-specific-langaugedsl-in-ruby-day-1/

module Hwk

  class Includable
    class << self
      attr_accessor :languages
    end

    def initialize( *q, &block )
      if self.class.languages.nil?
        self.class.languages = []
      end
    end

    def languages
      self.class.languages
    end

    def include_language( lang )
      self.class.languages << lang unless self.class.languages.include? lang
    end

    def include_source( file, options='', desc='' )
      lang_suff = File.extname( file )[1..-1]
      source_text = ""

      if ( lang_suff )
        include_language( lang_suff )
      else
        $stderr.puts "Warning, unable to determine file type of '#{file}', no extension"
      end

      source_name = File.basename( file, File.extname( file ) )
      abort( "File does not exist:#{source_name}" ) unless File.exists?( file )
      source_text = options + "\\#{lang_suff}script{#{source_name}}{#{desc}}"
    end

    def include_fig( file_name_sans_ext, fig_name, position_opt='h', options='width=.5\textwidth' )
      '\begin{figure}['+position_opt+']' +
      %q#\begin{center}
          \includegraphics[# + options + ']{' + file_name_sans_ext + '} \label{fig:'+fig_name+'}' +
      %q#\end{center}
        \end{figure}#
    end

    def include_tikz( file_name: 'nofilespecified', fig_name: 'no name figure',
        position_opt: 'h', width: '\columnwidth', height: '!' )
      s = '\begin{figure}['+position_opt+'] \begin{center}'
      s << '\resizebox{'+ width +'}{'+ height +'}{'
      if ( file_name.class == String ) 
             s << '\input{' + file_name + '.tex}'
      elsif ( file_name.class == Array )
        file_name.each do |f|
             s << '\input{' + f + '.tex}'
        end
      end
      s << '\label{fig:'+fig_name+'}}\end{center}\end{figure}'
    end

    def include_wrapped_tikz( file_name: 'nofilespecified', fig_name: 'no name figure',
        lineheight: '1', twidth: '0.5\textwidth', gheight: '!', gwidth: '0.48\textwidth',
        position: 'r' )
      s = '\begin{wrapfigure}{'+position+'}{'+twidth+'} \begin{center}'
      s << '\resizebox{'+ gwidth +'}{'+ gheight +'}{'
      if ( file_name.class == String ) 
             s << '\input{' + file_name + '.tex}'
      elsif ( file_name.class == Array )
        file_name.each do |f|
             s << '\input{' + f + '.tex}'
        end
      end
      s << '\label{fig:'+fig_name+'}}\end{center}\end{wrapfigure}'
    end
  end


  def adjust_caller_loc( loc, n )
    caller_parts = loc.match(/(.+):(\d+):(.+)/)

    unless caller_parts.nil?
      loc = "#{caller_parts[1]}:#{String(caller_parts[2].to_i+n)}:#{caller_parts[3]}" unless caller_parts.length != 4
    end

    return loc
  end

  def add_and_trace_from( add_str: nil, tr: nil, name: nil, loc: caller(0)[1], obj: nil )

    if add_str.nil?
      return ''
    end

    obj_id = self.object_id
    obj_id = obj.object_id unless obj.nil?

    add_str.lines.each { |l|
      tr_str = loc
        unless HWKTRACE.lines[ obj_id ].nil?
          unless HWKTRACE.lines[ obj_id ][ name ].nil?
            tr_str = HWKTRACE.lines[ obj_id ][ name ].hwk_line
          end
        end
      tr << tr_str unless tr.nil?
    }

    add_str
 end

end # module Hwk
