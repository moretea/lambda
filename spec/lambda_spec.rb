require "parslet/rig/rspec"
require "lambda/parser"

module Lambda
  describe LowLevelParser do
    let(:parser) { described_class.new }

    context "variable" do
      subject { parser.variable }

      it { should     parse('x').as(variable: 'x')}
      it { should     parse('xa').as(variable: 'xa')}

      it { should_not parse '\a' }
      it { should_not parse 'a b' }
    end

    context "abstraction" do
      subject { parser.abstraction }

      it { should parse("\\x. y").as(abstraction: {over: {variable: 'x'}, term: [variable: 'y']}) }
      it { should parse("\\x. \\y. \\z. x").as(abstraction: { over: {variable: 'x'}, term: [abstraction: {over: {variable: 'y'}, term: [abstraction: { over: {variable: 'z'}, term: [ variable: 'x'] }]}]}) }

      it { should parse("\\x. x y").as(abstraction: { over: {variable: 'x'}, term: [{variable: 'x' }, {variable: 'y'}]}) }

      it { should_not parse("x") }
      it { should_not parse("\\x") }
      it { should_not parse("\\x.") }
      it { should_not parse("\\x. ") }
    end

    context "term" do
      subject { parser.term }
      it { should     parse("a").as([variable: 'a']) }
      it { should     parse(" a").as([variable: 'a']) }
      it { should     parse("(a)").as([term: [variable: 'a']]) }
      it { should     parse("(((a)))").as([{:term=>[{:term=>[{:term=>[{:variable=>"a"}]}]}]}]) }
      it { should     parse("(a b)").as([{:term=>[{:variable=>"a"}, {:variable=>"b"}]}]) }
      it { should     parse("(a (b))").as([{:term=>[{:variable=>"a"}, {:term=>[{:variable=>"b"}]}]}]) }
      it { should     parse("(a (b c))").as([{:term=>[{:variable=>"a"}, {:term=>[{:variable=>"b"}, {:variable=>"c"}]}]}]) }
      it { should     parse("(a (b (c)))").as([{:term=>[{:variable=>"a"}, {:term=>[{:variable=>"b"}, {:term=>[{:variable=>"c"}]}]}]}]) }
      it { should     parse "(b) c" }
      it { should     parse "(a ((b) c))" }
      it { should parse("(\\x. x) y").as([{term: [{abstraction: { over: {variable: "x"}, term: [{ variable: "x" }]}}]}, {variable: "y"}]) }
      it { should_not parse "a)" }
    end
  end

  describe Transformer do
    subject {described_class.new.apply tree}

    describe "variable" do
      let(:tree) do {variable: 'x'} end

      it         { should be_kind_of Variable }
      its(:name) { should eql "x" }
    end

    describe "term and application" do
      context "one term" do
        let(:tree) do {term: [variable: 'x']} end

        it "expands into the inner type" do
          subject.should be_kind_of Variable
        end

        its(:name) { should eql "x" }
      end

      context "two terms" do
        let(:tree) do {term: [{variable: 'x'}, {variable: 'y'}]} end

        it "expands into the a application" do
          subject.should be_kind_of Application
        end

        its(:left)  { should be_kind_of Variable }
        its(:right) { should be_kind_of Variable }
        it { subject.left.name.should  eql 'x' }
        it { subject.right.name.should eql 'y' }
      end

      context "three terms" do
        let(:tree) do {term: [{variable: 'x'}, {variable: 'y'}, {variable:'z'}]} end

        it "expands into the a application" do
          subject.should be_kind_of Application
        end

        its(:left)  { should be_kind_of Application}
        its(:right) { should be_kind_of Variable }
        it { subject.left.left.name.should   eql 'x' }
        it { subject.left.right.name.should  eql 'y' }
        it { subject.right.name.should       eql 'z' }
      end
    end

    describe "abstraction" do
      context "over one variable" do
        let(:tree) do {abstraction: {over: {variable: 'x'}, term: [variable: 'y']}} end
        it         { should be_kind_of Abstraction}
        its(:over) { should be_kind_of Variable }
        its(:body) { should be_kind_of Variable }
        it { subject.over.name.should eql 'x' }
        it { subject.body.name.should eql 'y' }
      end

      context "with an application" do
        let(:tree) do {abstraction: {over: {variable: 'x'}, term: [{variable: 'y'}, {variable: 'z'}]}} end
        it         { should be_kind_of Abstraction}
        its(:over) { should be_kind_of Variable }
        its(:body) { should be_kind_of Application }
      end
    end
  end
end
