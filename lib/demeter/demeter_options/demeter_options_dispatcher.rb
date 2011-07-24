require File.expand_path("options", File.dirname(__FILE__))
require File.expand_path("delegate_adder", File.dirname(__FILE__))

class DemeterOptionsDispatcher
  attr_accessor :to_be_demetered, :default_name
  def initialize klass
    @klass = klass
    self.to_be_demetered = []
  end
  def simple_list_of_demeter_names? *args
    not args.empty? and
    args.inject(true) {|x,y| x and (y.is_a? String or y.is_a? Symbol)}
  end
  def dispatch! *args
    if simple_list_of_demeter_names? *args
      args.each do |a|
        to_be_demetered << a 
      end
    else
      options = DemeterOptions.new
      yield options
      options.sub_options.each do |s_o|
        to_be_demetered << s_o.name
      end
      default_s_o = options.sub_option_with_default

      if not default_s_o.nil?
        default_s_o.delegate_options.each do |d_o|
          @klass.class_eval do
            define_method(d_o.incoming) do |*args, &block|
              full_name =  default_s_o.name.to_s + '_' + d_o.receiving.to_s
              self.send full_name, *args, &block
            end
          end
        end
      end

      self.default_name = default_s_o.name unless default_s_o.nil?
      DelegateAdder.new(@klass).add_methods! options
    end
  end
end
