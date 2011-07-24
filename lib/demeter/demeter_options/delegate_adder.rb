class DelegateAdder
  def initialize klass
    @klass = klass
  end
  def add_methods! options
    options.sub_options.each do |s_o|
      self.add_method! s_o
    end
  end
  def add_method! sub_option
    sub_option.delegate_options.each do |d_o|
      @klass.class_eval do
        object_name_prefix = sub_option.name.to_s + '_'

        receiving_name = d_o.receiving.to_s
        incoming_name = d_o.incoming.to_s

        incoming_method = object_name_prefix + incoming_name
        receiving_method = object_name_prefix + receiving_name

        define_method(incoming_method) do |*args|
          self.send *([receiving_method] + args)
        end
      end
    end
  end
end
