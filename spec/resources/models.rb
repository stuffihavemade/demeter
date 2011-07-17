class Project < ActiveRecord::Base
  has_many :tasks
end

class Task < ActiveRecord::Base
  belongs_to :project
  has_one :owner

  accepts_nested_attributes_for :project
end

class Owner < ActiveRecord::Base
  belongs_to :task
end

class Implicit < ActiveRecord::Base
  has_one :sub
  belongs_to :super
end

class Sub < ActiveRecord::Base
  belongs_to :implicit
end

class Super < ActiveRecord::Base
  has_many :implicits
end
