module AwesomeSausage::Arel
  extend ::ActiveSupport::Concern

  include ::Arel::Math
  include ::Arel::Predications

  {
    lt: :<,
    lteq: :<=,
    gt: :>,
    gteq: :>=,
    eq: :==,
    not_eq: :!=,
    matches: :=~,
    does_not_match: :!~
  }.each do |method, operator|
    define_method(operator) { |other| send(method, other).extend(Arel) }
  end

  [:+, :-, :/, :*].each do |operator|
    define_method(operator) { |other| super(other).extend(Arel) }
  end

  def %(other)
    ::Arel::Nodes::InfixOperation.new('%', self, other).extend Arel
  end

  def div(other)
    ::Arel::Nodes::InfixOperation.new('DIV', self, other).extend Arel
  end

  def to_sql
    ::Arel::Table.engine.connection.visitor.accept self
  end

  def is(*args)
    args = args.flatten.uniq
    case args.size
    when 0
      raise ArgumentError, 'wrong number of arguments (0 for 1+)'
    when 1
      eq(args)
    else
      self.in(args)
    end
  end

  def is_not(*args)
    is(args).not
  end

  def sums(as = nil)
    sum.as("#{as || name}_sum")
  end

  def counts(as = nil)
    count.as("#{as || name}_count")
  end

  def averages(as = nil)
    average.as("#{as || name}_average")
  end

  def percentages(divisor, as = nil)
    sum_without_alias./(divisor.sum_without_alias).as("#{as || name}_pct")
  end

  def sum_without_alias
    ::Arel::Nodes::Sum.new([self]).extend(::Arel::Math)
  end

end
