class User
  attr_accessor :name
  attr_accessor :address
  attr_accessor :video_game
  attr_accessor :profile

  extend Demeter

  def initialize
    @video_game = VideoGame.new
    @address = Address.new
    @profile = Profile.new
  end
end

class Address
  attr_accessor :street
  attr_accessor :city
  attr_accessor :country
  attr_accessor :state
  attr_accessor :zip_code
  attr_accessor :coordinate

  extend Demeter

  def initialize
    @coordinate = Coordinate.new
  end
  def last_of_arbitrary_number_of_args *args
    args[-1]
  end
end

class Coordinate
  attr_accessor :lat
  attr_accessor :lon

  def last_of_arbitrary_number_of_args *args
    args[-1]
  end
end

class VideoGame
  attr_accessor :title
  attr_accessor :production_year
end

class Profile
  attr_accessor :interests
end

class Person
  extend Demeter
  attr_accessor :animal

  def initialize
    @animal = Animal.new
  end
end

class Animal
  attr_accessor :name
end

class NoAccessorsParent
  extend Demeter
  demeter :no_accessors_child
end

class NoAccessorsChild
end

class SingleWithOptions
  extend Demeter
  demeter do |d|
    d.has :address do |a|
      a.is_default
      a.delegates(:zip).to :zip_code
      a.delegates(:l).to :last_of_arbitrary_number_of_args
    end
  end

  def initialize
    @address = Address.new
  end
end

class WithTooManyDefaults
  extend Demeter
end

class TwoWithOneOption
  extend Demeter
  demeter do |d|
    d.has :address do |a|
      a.delegates(:zip).to :zip_code
    end
    d.has :animal do |a|
      a.is_default
    end
  end
end

class ParentClassDefault
  def method_missing name, *args
    :passed
  end
end

class NilClass
  def passed
    :failed
  end
end

class ChildClassDefault < ParentClassDefault
  extend Demeter
  demeter do |d|
    d.has :address do |a|
      a.is_default
      a.delegates(:zip).to :zip_code
      a.delegates(:l).to :last_of_arbitrary_number_of_args
    end
  end
end

class WithAndWithoutOptions
  extend Demeter
  demeter do |d|
    d.has :animal
    d.has :address do |a|
      a.is_default
      a.delegates(:zip).to :zip_code
    end
  end

  def initialize
    @animal = Animal.new
    @address = Address.new
  end
end
