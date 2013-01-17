require "readline"

module Lambda
  class Repl
    def self.start
      new.start
    end

    def start
      start_banner
      while cmd = Readline.readline("> ", true)
        process cmd.chomp
      end
    end

    def start_banner
      puts "Lambda REPL"
      puts
      puts "Usage: type :help for more information"
    end

    def process cmd
      case cmd
        when /^:help$/ then print_help
        when /^:tree(.*)$/ then print_tree($1)
        else; puts "Unkown command"
      end
    end

    def print_help
      puts <<-EOH
      :help                     Prints help
      :tree <lambda expression> Prints the expression in tree format
      End of stream (CTRL + D)  Quit
      EOH
    end

    def parse lexpr
      begin
        Lambda::Parser.parse lexpr
      rescue Parslet::ParseFailed => error
        puts error.cause.ascii_tree
        nil
      end
    end

    def print_tree str
      if (l = parse(str))
        Lambda::Printer.new.tree l
      end
    end
  end
end
