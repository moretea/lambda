require "lambda"

module Lambda
  describe Concept do
    describe "#descendants" do
      context "of variable" do
        subject { Variable.new("x") }
        its(:descendants) { should == [] }
      end

      context "of abstraction " do
        let(:over) { Variable.new("x") }
        let(:body) { Variable.new("y") }
        subject { Abstraction.new(over, body) }
        its(:descendants) { should == [body] }
      end

      context "of applications" do
        let(:top)         { Application.new(top_left, top_right) }
        let(:top_left)    { Application.new(other_left, other_right) }
        let(:top_right)   { Variable.new("p") }
        let(:other_left)  { Variable.new("q") }
        let(:other_right) { Variable.new("r") }

        subject { top }

        its(:descendants) { should =~ [top_left, top_right, other_left, other_right] }
      end
    end

    context "#redexes" do
      context "the concept itself" do
        subject do
          Application.new(
            Abstraction.new(Variable.new("x"), Variable.new("x")),
            Variable.new("y")
          )
        end

        it { subject.redexes.should == [subject] }

        its(:redexes) { should be_kind_of Array }
      end
    end
  end
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
