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
  demeter :address => [:default,
                       :delegate => {:zip => :zip_code,
                                     :l => :last_of_arbitrary_number_of_args}]
  def initialize
    @address = Address.new
  end
end

class WithTooManyDefaults
  extend Demeter
end

class TwoWithOneOption
  extend Demeter
  demeter :address => {:delegate => {:zip => :zip_code}}, :animal => :default
end



class WithAndWithoutOptions
  extend Demeter
  demeter :animal,
          :address => [:default, :delegate => {:zip => :zip_code}]

  def initialize
    @animal = Animal.new
    @address = Address.new
  end
end
