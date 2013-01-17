# encoding: UTF-8
require_relative "parser"

module Lambda
  class Printer
    def initialize(to = $stdout)
      @to = to
    end

    def tree term, prefix = "", child_prefix = ""
      case term
      when Variable
        @to.puts "#{prefix}#{term.name}"
      when Abstraction
        @to.puts "#{prefix}λ#{term.over.name}"
        self.tree(term.body, child_prefix + "└──", child_prefix + "   ")
        
      when Application
        @to.puts "#{prefix}@"
        self.tree(term.left,  child_prefix + "├──", child_prefix + "│  ")
        self.tree(term.right, child_prefix + "└──", child_prefix + "   ")
      else
        raise "UNKNOWN #{term.inspect}"
      end
    end
  end
end
