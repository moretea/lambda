module Lambda
  class Concept
    def redexes
      self_and_desendants.select { |concept| concept.kind_of?(Application) && concept.is_redex? }
    end

    def self_and_desendants
      descendants << self
    end

    def descendants
      if children.any?
        children.collect(&:self_and_desendants).flatten
      else
        []
      end
    end
  end

  class Variable < Concept
    attr_reader :name
    def initialize name
      @name = name
    end

    def children
      []
    end
  end

  class Abstraction < Concept
    attr_reader :over, :body
    def initialize over, body
      @over = over
      @body = body
    end

    def children
      [body]
    end
  end

  class Application < Concept
    attr_reader :left, :right

    def initialize left, right
      @left  = left
      @right = right
    end

    def is_redex?
      @left.kind_of? Abstraction
    end

    def children
      [left, right]
    end
  end
end
