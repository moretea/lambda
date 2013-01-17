require "parslet"

module Lambda
  module Parser
    def self.parse str
      Transformer.new.apply LowLevelParser.new.parse(str, reporter: Parslet::ErrorReporter::Deepest.new)
    end
  end

  class LowLevelParser < Parslet::Parser
    root(:root_term)

    rule(:space)  { str(" ") }
    rule(:spaces) { space.repeat(1) }
    rule(:spaces?) { spaces.maybe }

    rule(:root_term) { term.as(:term) }
    rule(:term)        { spaces? >> (abstraction | variable | subterm).repeat(1)}
    rule(:subterm)     { str("(") >> term.as(:term) >> str(")") >> spaces? }
    rule(:var_name)    { (match['a-z'] >> match["a-z0-9_'"].repeat) }
    rule(:variable)    { var_name.as(:variable) >> spaces?}
    rule(:abstraction) { (str("\\") >> variable.as(:over) >> (spaces >> variable).repeat >> str(".") >> spaces? >> term.as(:term)).as(:abstraction) >> spaces? }
  end

  class Transformer < Parslet::Transform
    rule(variable: simple(:name)) do
      Variable.new(name)
    end

    rule(term: sequence(:parts)) do
      if parts.length == 1
        parts.first
      else
        parts.inject do |left, right|
          Application.new(left, right)
        end
      end
    end

    rule(abstraction: { over: simple(:over), term: sequence(:terms) }) do
      if terms.length == 0
        raise "Unexpected abstraction body: #{terms.inspect}"
      elsif terms.length == 1
        Abstraction.new(over, terms.first)
      else
        applications = terms.inject do |left, right|
          Application.new(left, right)
        end
        Abstraction.new(over, applications)
      end
    end
  end
end
