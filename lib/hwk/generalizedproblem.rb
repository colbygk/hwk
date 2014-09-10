
# yoinked from: http://raycodingdotnet.wordpress.com/2013/08/11/writing-domain-specific-langaugedsl-in-ruby-day-1/


class GeneralizedProblem
  [:enumstyle,:itemcustom, :start,:question,:solution].each do |m|
    self.class_eval("def #{m}(param=nil); param.nil?  ? @#{m} : (@#{m} = param); end")
  end

  def add( subproblem )
    if (@subproblems == nil )
      @subproblems = []
    end

    @subproblems << subproblem
  end

  def subproblems 
    @subproblems
  end

  def initialize &block
    enumstyle( 'alph' )
    (block.arity < 1 ?  (instance_eval &block) : block.call(self)) if block_given?
  end

  def to_s
    "GeneralizedProblem.to_s not implemented"
  end
end
