ActiveRecord::Schema.define(:version => 0) do
  create_table :projects do |t|
    t.string :name
  end

  create_table :tasks do |t|
    t.string :name
    t.references :owner, :project
  end

  create_table :owners do |t|
    t.string :name
    t.references :owner
  end

  create_table :implicits do |t|
    t.references :super
  end

  create_table :subs do |t|
    t.references :implicit
  end

  create_table :supers do |t|
  end
end
