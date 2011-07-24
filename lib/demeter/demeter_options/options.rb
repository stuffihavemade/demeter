class DemeterOptions
  attr_accessor :sub_options
  def initialize
    self.sub_options = []
  end
  def has name
    sub = DemeterSubOption.new
    sub.name = name
    self.sub_options << sub
    yield sub if block_given?
    if more_than_one_default?
      message = 'At most one default object may be defined per class.'
      raise MoreThanOneDefaultDefinedError.new message
    end
  end
  def more_than_one_default? 
    sub_options.find_all do |s|
      s.is_default?
    end.size > 1
  end
  def sub_option_with_default
    self.sub_options.find {|o| o.is_default?}
  end
end

class MoreThanOneDefaultDefinedError < RuntimeError
end

class DemeterSubOption
  attr_accessor :name, :delegate_options
  def initialize
    self.delegate_options = []
    @is_default = false
  end
  def is_default?
    @is_default
  end
  def is_default
    @is_default = true
  end
  def delegates incoming_message_name
    delegate_option = DelegateOption.new
    delegate_option.incoming = incoming_message_name
    delegate_options << delegate_option
    delegate_option
  end
end

class DelegateOption
  attr_accessor :incoming, :receiving
  def to receiving_message_name
    self.receiving = receiving_message_name
  end
end
