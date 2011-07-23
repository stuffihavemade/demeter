module Demeter
  def self.extended(base)
    base.class_eval do
      include InstanceMethods
      extend ClassMethods

      class << self
        attr_accessor :demeter_names
      end

      base.demeter_names = []
    end
  end

  module InstanceMethods
    def method_missing(method_name, *attrs, &block)
      object_method_name = method_name.to_s
      object_name = self.class.demeter_names.find {|name| object_method_name =~ /^#{name}_/ }

      return super unless object_name

      object_method_name.gsub!(/^#{object_name}_/, "")

      self.define_singleton_method(method_name) do
        target  = self.send object_name
        target.send *([object_method_name] + attrs) if not target.nil?
      end

      send(method_name)
    end

    def respond_to?(method_name, include_private = false)
      object_method_name = method_name.to_s
      object_name = self.class.demeter_names.find {|name| object_method_name =~ /^#{name}_/ }

      if object_name && (object = send(object_name))
        object.respond_to?(object_method_name.gsub(/^#{Regexp.escape(object_name.to_s)}_/, ""))
      else
        super
      end
    end
  end

  module ClassMethods
    def demeter(*attrs)
      if attrs.inject(true){|x,y| x and y.is_a? Symbol}
        self.demeter_names = attrs
        self.class_eval do
          attrs.each do |name|
            attr_accessor name
          end
        end
      end
    end
  end
end

# ActiveRecord support
require "demeter/active_record"
