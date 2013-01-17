require "lambda"

module Lambda
  describe Application do
    context "#is_redex?" do
      subject { Application.new(left, right) }
      let(:right) { Variable.new("y") }

      context "with left child = abstraction" do
        let(:left)  { Abstraction.new(Variable.new("x"), Variable.new("x")) }
        its(:is_redex?) { should == true }
      end

      context "with left child = variable " do
        let(:left)  { Variable.new("q") }
        its(:is_redex?) { should == false }
      end

      context "with left child = application" do
        let(:left)  { Application.new(Variable.new("p"), Variable.new("q")) }
        its(:is_redex?) { should == false }
      end
    end
  end
end
