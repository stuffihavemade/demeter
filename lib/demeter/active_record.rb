class ActiveRecord::Base
  def self.inherited(base)
    super
    base.send :extend, ::Demeter
  end
  class << self
    alias :belongs_to_fefda791 :belongs_to
    alias :has_one_b66cd805 :has_one
    alias :has_many_0ca27733 :has_many
    alias :has_and_belongs_to_many_7fe5eedb :has_and_belongs_to_many
    def association_to_demeter *args, &block
      first = args.first
      if not self.demeter_names.include? first
        self.demeter_names << first
      end
      block.call *args
    end

    def belongs_to *args
      association_to_demeter(*args) {|*x| belongs_to_fefda791 *x}
    end
    def has_one *args
      association_to_demeter(*args) {|*x| has_one_b66cd805 *x}
    end
    def has_many *args
      association_to_demeter(*args){|*x| has_many_0ca27733 *x}
    end
    def has_and_belongs_to_many *args
      association_to_demeter(*args) {|*x| has_and_belongs_to_many_7fe5eedb *x}
    end
  end
end if defined? ActiveRecord::Base
