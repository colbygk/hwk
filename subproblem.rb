
# 
#

require 'generalizedproblem'

class Subproblem < GeneralizedProblem

  def initialize &block
    super &block
    enumstyle( '\roman' )
  end

  def to_s
    problem_str = '\item'
    if ( itemcustom )
      problem_str << '[' << itemcustom << '] '
    else
      problem_str << ' '
    end

    problem_str << question.to_s << "\n\\par\n"

    if ( solution.to_s.length > 0 )
      problem_str << '\problemAnswer{' << solution.to_s << "}\n"
    end

    if ( subproblems && subproblems.length > 0 )
      problem_str << '\begin{enumerate}[label=(' <<  enumstyle << '*)]'
      subproblems.each do |subp|
        problem_str << subp.to_s << "\n"
      end
      problem_str << '\end{enumerate}' << "\n"
    end

    problem_str
  end

end

