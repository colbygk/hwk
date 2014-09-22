
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

  end
end
