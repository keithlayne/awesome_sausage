module AwesomeSausage::ActiveRecord
  extend ::ActiveSupport::Concern

  AS = AwesomeSausage

  included do |base|
    raise TypeError.new('AwesomeSausage::ActiveRecord must be included from a subclass of ActiveRecord::Base') unless base <= ::ActiveRecord::Base
    STDERR.puts 'Monkey-patching ActiveRecord::Base with AwesomeSausage::ActiveRecord...' if base == ::ActiveRecord::Base

    column_names.each do |column|
      method = respond_to?(column) && "#{column}_column" || column
      define_singleton_method(method) do
        var = "@#{method}".to_sym
        instance_variable_get(var) ||
          instance_variable_set(var, arel_table[column].extend(AS::Arel))
      end
    end
  end

  module ClassMethods

    def *
      @star ||= arel_table[::Arel.star].extend(AS::Arel)
    end

    if ::ActiveRecord::VERSION::MAJOR < 4
      def none
        @none ||= where('1 = 0')
      end

      def find_by(*args)
        where(*args).first
      end

      def find_by!(*args)
        find_by(*args) || raise('Not Found')
      end
    end

    def make_if(condition, if_value = nil, else_value = nil)
      ::Arel.sql(%{CASE WHEN #{
          sqlify(condition)
        } THEN #{
          sqlify(if_value) || 1
        } ELSE #{
          sqlify(else_value) || 'NULL'
        } END}).extend AS::Arel
    end

    def count_if(condition)
      make_if(condition).count.extend AS::Arel
    end

    def sum_if(condition)
      make_if(condition).sum.extend AS::Arel
    end

    def case_when(switch, values, default = nil)
      ::Arel.sql(%{CASE #{
          switch && switch.to_sql
        } #{
          values.map { |key, value| "WHEN #{key} THEN '#{value}' " }.sum
        } #{
          "ELSE '#{default}'" if default
        } END}).extend AS::Arel
    end

    def function(name, *args)
      ::Arel::Nodes::NamedFunction.new(name, args).extend(AS::Arel)
    end

    private

    def sqlify(term)
      term.respond_to?(:to_sql) && term.to_sql || connection.quote(term)
    end
  end

end
