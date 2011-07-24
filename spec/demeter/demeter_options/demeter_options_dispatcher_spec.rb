require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe DemeterOptionsDispatcher do
  it "works with the old style declaration methods" do
    klass = Class.new
    d = DemeterOptionsDispatcher.new klass
    d.dispatch! :hello, :goodbye
    d.to_be_demetered.should == [:hello, :goodbye]
    d.default_name.should == nil
  end

  it "works with the DSL style declaration methods" do
    klass = Class.new
    d = DemeterOptionsDispatcher.new klass
    d.dispatch! do |d|
      d.has :hello
      d.has :goodbye
    end
    d.to_be_demetered.should == [:hello, :goodbye]
    d.default_name.should == nil
  end

  it "allows the defintion of a default child object" do
    klass = Class.new
    default_class = Class.new
    d = DemeterOptionsDispatcher.new klass
    d.dispatch! do |d|
      d.has :hello do |h|
        h.is_default
      end
    end
    d.default_name.should == :hello
  end

  it "allows the definition of exactly one child object" do
    klass = Class.new
    default_class = Class.new
    d = DemeterOptionsDispatcher.new klass
    doing do
      d.dispatch! do |d|
        d.has :hello do |h|
          h.is_default
        end
        d.has :goodbye do |g|
          g.is_default
        end
      end
    end.should raise_error MoreThanOneDefaultDefinedError
  end

  it "allows delegation from one message name to another" do
    klass = Class.new
    d = DemeterOptionsDispatcher.new klass
    d.dispatch! do |d|
      d.has :hello do |h|
        h.delegates(:greet).to :greeting
      end
    end
    klass.new.should respond_to :hello_greet
  end

  it "allows for combination of default and delegation" do
    klass = Class.new

    class Hello
      def greeting
        'hi'
      end
    end

    d = DemeterOptionsDispatcher.new klass
    d.dispatch! do |d|
      d.has :hello do |h|
        h.is_default
        h.delegates(:greet).to :greeting
      end
    end
    klass.new.should respond_to :greet
  end

end
