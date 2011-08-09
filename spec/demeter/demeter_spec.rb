require File.expand_path("../spec_helper", File.dirname(__FILE__))

describe "Demeter" do
  subject { User.new }

  before do
    User.demeter :address, :video_game
    Address.demeter :coordinate

    subject.name = "John"
    subject.address.street = "Some street"
    subject.address.zip_code = "98005"
    subject.address.coordinate.lat = 75.0
    subject.address.coordinate.lon = 85.0
    subject.video_game.title = "God of War 3"
    subject.video_game.production_year = 1999
    subject.profile.interests = %w(games programming music movies)
  end

  it "should respond to demeterized methods" do
    User.demeter :address
    user = User.new

    user.should respond_to(:address_street)
    user.should respond_to(:address_city)
    user.should respond_to(:address_country)
    user.should respond_to(:address_state)
    user.should respond_to(:address_zip_code)
  end

  it "should respond to nested demeterized methods" do
    User.demeter :address
    Address.demeter :coordinate
    user = User.new

    user.should respond_to(:address_coordinate_lat)
    user.should respond_to(:address_coordinate_lon)
  end

  it "should keep responding to instance methods" do
    User.demeter :address
    user = User.new

    user.should respond_to(:name)
    user.should respond_to(:address)
    user.should respond_to(:video_game)
    user.should respond_to(:profile)
    user.should respond_to(:methods)
    user.should respond_to(:public_methods)
  end

  it "should not respond to unknown methods" do
    User.demeter :address
    user = User.new

    user.should_not respond_to(:video_game_title)
    user.should_not respond_to(:video_production_year)
    user.should_not respond_to(:profile_interests)
  end

  it "should allow demeter only one object" do
    Person.demeter :animal
    person = Person.new
    person.animal.name = "marley"

    person.animal_name.should == "marley"
  end

  it "should not delegate existing methods" do
    subject.name.should == "John"
  end

  it "should delegate methods from address object" do
    subject.address_street.should == "Some street"
    subject.address_zip_code.should == "98005"
  end

  it "should delegate methods from video game object" do
    subject.video_game_title.should == "God of War 3"
    subject.video_game_production_year.should == 1999
  end

  it "should delegate nested methods from coordinate object" do
    subject.address_coordinate_lat.should == 75.0
    subject.address_coordinate_lon.should == 85.0
  end

  it "should delegate setters to nested methods from coordinate object" do
    subject.address_coordinate_lat = -75.0
    subject.address_coordinate_lat.should == -75.0
    subject.address_coordinate_lon = -85.0
    subject.address_coordinate_lon.should == -85.0
  end

  it "should be able to pass in an arbitary number of arguments" do
    result = subject.address_coordinate_last_of_arbitrary_number_of_args(1,2,3)
    result.should == 3
  end

  it "should have accessors defined automatically" do

    NoAccessorsParent.new.should respond_to(:no_accessors_child)
    NoAccessorsParent.new.should respond_to(:no_accessors_child=)
  end

  it "should return nil when demeter object is not set" do
    subject.address = nil
    subject.address_title.should be_nil
  end

  it "should return nil when nested demeter object is not set" do
    subject.address = nil
    subject.address_coordinate_lat.should be_nil
  end

  it "should raise exception when method is not defined on the demeter class" do
    doing { subject.address_foo }.should raise_error(NoMethodError)
  end

  it "should not delegate unset objects" do
    doing { subject.profile_interests }.should raise_error(NoMethodError)
  end

  it "should override demeter method" do
    subject.instance_eval do
      def address_street
        address.street.upcase
      end
    end

    subject.address_street.should == "SOME STREET"
  end

  it "should replace demeter names" do
    User.demeter_names = []
    User.demeter_names.should == []

    doing { subject.address_title }.should raise_error(NoMethodError)
  end

  it "should respond to a message directly to a child marked default" do
    single = SingleWithOptions.new
    single.should respond_to(:city)
  end

  it "should send a message directly to a child marked default" do
    single = SingleWithOptions.new
    single.address.city = "hello"
    single.city.should == "hello"
  end

  it "should still be able to send normal messages to a child marked default" do
    single = SingleWithOptions.new
    single.address.city = "hello"
    single.address_city.should == "hello"
  end


  it "should still be able to respond to normal messages to a child marked default" do
    single = SingleWithOptions.new
    single.should respond_to(:address_city)
  end

  it "should not send a message to a default child that it understands" do
    single = SingleWithOptions.new
    single.define_singleton_method(:city) {:passed}
    single.city.should == :passed
  end

  it "should raise an error if more than one default is defined" do
    doing do
      WithTooManyDefaults.demeter do |d|
        d.add :address do |a|
          a.is_default_with_class Address
        end
        d.add :animal do |a|
          a.is_default_with_class Animal
        end
      end
    end.should raise_error
  end

  it "should be able to work with and without options simultaneously" do
    options = WithAndWithoutOptions.new
    options.should respond_to(:animal_name)
    options.should respond_to(:address_city)
  end

  it "should be able to delegate an incoming message to a different message" do
    single = SingleWithOptions.new
    single.address.zip_code = 12345
    single.address_zip.should == 12345
  end

  it "should allow default and delegate to work together" do
    single = SingleWithOptions.new
    single.address.zip_code = 12345
    single.zip.should == 12345
  end

  it "should be able to respond correctly for a delegated method" do
    single = SingleWithOptions.new
    single.should respond_to(:address_zip)
  end

  it "should be able to delegate an incoming message with an arbitrary number of arguments" do
    single = SingleWithOptions.new
    single.address_l(1,2,3).should == 3
  end
  describe Demeter::ClassMethods do
    it "should return an array of demeter_names" do
      User.demeter_names.should be_kind_of(Array)
    end
  end
end
