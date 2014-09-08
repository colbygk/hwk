
# yoinked from: http://raycodingdotnet.wordpress.com/2013/08/11/writing-domain-specific-langaugedsl-in-ruby-day-1/

require 'generalizedproblem'
require 'subproblem'

class Problem < GeneralizedProblem

  def initialize &block
    super &block
    enumstyle( '\alph' )
  end

  def to_s
    problem_str = '\begin{homeworkProblem}' << "\n"
    problem_str << question.to_s << "\n\\par\n"

    if ( solution.to_s.length > 0 )
      problem_str << '\problemAnswer{' << solution.to_s << "}\n"
    end

    if ( subproblems && subproblems.length > 0 )
      problem_str << '\begin{enumerate}[label=(' << enumstyle << '*)]' << "\n"
      subproblems.each do |subp|
        problem_str << subp.to_s << "\n"
      end
      problem_str << '\end{enumerate}' << "\n"
    end

    problem_str << '\end{homeworkProblem}' << "\n" 
    problem_str
  end
end
