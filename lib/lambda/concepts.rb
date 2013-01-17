module Lambda
  class Variable
    attr_reader :name
    def initialize name
      @name = name
    end
  end

  class Abstraction
    attr_reader :over, :body
    def initialize over, body
      @over = over
      @body = body
    end
  end

  class Application
    attr_reader :left, :right

    def initialize left, right
      @left  = left
      @right = right
    end

    def is_redex?
      @left.kind_of? Abstraction
    end
  end
end
