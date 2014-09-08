
#
#

require 'singleton'

require 'problem'

class Homework
  include Singleton
  attr_accessor :title, :due_date, :class_name, :class_time, :author_name
  attr_accessor :code_inclusion_configuration, :class_professor
  attr_reader :identifier

  def initialize
    @debug = false
    @title = "No title Set"
    @due_date = Date.new
    @class_name = "No class_name Set"
    @class_time = "No class_time Set"
    @class_professor = "No class_professor Set"
    @author_name = "No author_name Set"
    @code_inclusion_configuration = "% no code"

    @identifier = { :prefix => 'HWK_', :suffix => '_HWK' }
    @ident_substr = @identifier[:prefix].length..(-1*(@identifier[:suffix].length+1))
    @ident_regex = /#{@identifier[:prefix]}\S+#{@identifier[:suffix]}/

    @problems = []
  end

  def add_problem( problem )
    @problems << problem
  end

  def resolve_call( c )
    begin
      v = eval( "Homework.instance."+c )
      if ( v.is_a?(String) )
        v = escape_string_for_latex( v )
      elsif ( v.is_a?(Array) )
        vs = ""
        v.each do |e|
          vs << e.to_s
        end
        v = vs
      elsif v.is_a?(Date)
        v = v.strftime("%a, %e %b %Y %H:%M")
      end
    rescue NoMethodError
      v = "Unknown reference: " + c
    rescue TypeError => te
      abort( "TypeError at "+ te.backtrace[0].split(':')[0..1].join(':') + " call:" + c )
    rescue NameError => ne
      abort( "NameError at "+ ne.backtrace[0].split(':')[0..1].join(':') + " call:" + c )
    end
    v
  end

  def escape_string_for_latex( s )
    if s.is_a?(String)
      s.gsub(/([&$#_{}~^])/, '\\\\\1')
    elsif s == nil
      ""
    else
      s
    end
  end

  def problems_loop
    problem_block = []

    @problems.each do |problem|
      problem_block << problem
    end

    problem_block
  end

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
  end

end

