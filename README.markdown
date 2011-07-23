Demeter
=======

The Law of Demeter (LoD), or Principle of Least Knowledge, is a simple design style for developing software with the following guidelines:

* Each unit should have only limited knowledge about other units: only units "closely" related to the current unit.
* Each unit should only talk to its friends; don't talk to strangers.
* Only talk to your immediate friends.

Installation
------------

	sudo gem install demeter

Usage
-----

	require "demeter"

	class User
	  extend Demeter

	  demeter :address

	  attr_accessor :name
	  attr_accessor :address

	  def initialize
	    @address = Address.new
	  end
	end

	class Address
	  attr_accessor :country
	end

	user = User.new
	user.address.country = "Brazil"
	user.address_country
	#=> Brazil

If your using ActiveRecord, you don't have to extend the `Demeter` module.

	class User < ActiveRecord::Base
	  has_one :address
	  demeter :address
	end

	user = User.first
	user.address_country

You can easily override a method that has been "demeterized"; just declare it before or after calling the `demeter` method.

	class User < ActiveRecord::Base
	  has_one :address
	  demeter :address

	  def address_country
	    @address_country ||= address.country.upcase
	  end
	end

Demeter will automatically defined accessor methods from relationship defined. So, for

	class User < ActiveRecord::Base
	  demeter :address
	end

	class Address < ActiveRecord::Base
	  demeter :coordinate
	end

	class Coordinate < ActiveRecord::Base
	  demeter :coordinate
	end

the methods

    user.address_coordinate

and

    user.address_coordinate=

will be defined automatically. Note that attempting to assign to coordinate
while having a nil address will throw an error.

Demeter will also automatically be defined for ActiveRecord relationships. So, for

	class User < ActiveRecord::Base
	  has_one :address
	end

the demeter method

      user.address_country 

will automatically be defined. IMPORTANT NOTE: to retain backwards compatiblity,
if the demeter macro method is used in a class, then the implicit ActiveRecord 
demeter methods will cease to work, and will need to be defined explicitly. So, for

	class User < ActiveRecord::Base
	  has_one :address
          demeter :other
	end

the demeter method

      user.address_country 

will no longer be defined. Instead, use

	class User < ActiveRecord::Base
	  has_one :address
          demeter :other, :address
	end
.

The 'Demeter' module also currently two options: default and delegate. Default
allows for any message passed to a parent object that is not understood to be first send to a designated child object, before being sent to the superclass. So, for

	class User 
          demeter :address => :default
	end

the demeter method

    user.country

is valid. Defining more than one default at a time e.g.

	class User
          demeter :address => :default, :animal => :default
	end

will cause an error to be raised.

Delegate allows redirecting an incoming message to another message. For example,

	class User 
          demeter :address => {:delegate => {:zip => :zip_code}}
	end

will make the demeter method

      user.address_zip

exhibit the same behavior as

      user.address_zip_code

Delegate and default can be used together, and with multiple demeters at once.
For example, 
  
      class User
        extend Demeter
        demeter :animal,
                :address => [:default, :delegate => {:zip => :zip_code}]
      end

.
To-Do
-----

* Allow demeter methods to be defined automatically recursively
* RDoc

Maintainer
----------

* Emerson Macedo (<http://codificando.com/>)

Contributor
-----------

* Nando Vieira (<http://simplesideias.com.br/>)
* Tino Gomes (<http://blog.tinogomes.com/>)
* stuffihavemade (<http://github.com/stuffihavemade/>)

License:
--------

(The MIT License)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
