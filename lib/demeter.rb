module Demeter
  def self.extended(base)
    base.class_eval do
      include InstanceMethods
      extend ClassMethods

      class << self
        attr_accessor :demeter_names, :demeter_default_child
      end

      base.demeter_names = []
      base.demeter_default_child = nil
    end
  end

  module InstanceMethods
    def method_missing(method_name, *attrs, &block)
      object_method_name = method_name.to_s
      object_name = self.class.demeter_names.find {|name| object_method_name =~ /^#{name}_/ }

      if object_name.nil?
        child = self.class.demeter_default_child
        if (not child.nil?) and ((self.send child).respond_to? method_name)
          return (self.send child).send *([method_name] + attrs)
        else
          return super
        end
      end

      object_method_name.gsub!(/^#{object_name}_/, "")

      self.define_singleton_method(method_name) do
        target  = self.send object_name
        target.send *([object_method_name] + attrs) if not target.nil?
      end

      send(method_name)
    end

    def respond_to?(method_name, include_private = false)
      if super
        return true
      end

      object_method_name = method_name.to_s
      object_name = self.class.demeter_names.find {|name| object_method_name =~ /^#{name}_/ }


      if object_name && (object = send(object_name))
        object.respond_to?(object_method_name.gsub(/^#{Regexp.escape(object_name.to_s)}_/, ""))
      else
        child = self.class.demeter_default_child
        if not child.nil?
          (self.send child).respond_to? method_name
        else
          false
        end
      end
    end
  end

  module ClassMethods
    def eval_hash hash, to_be_demetered
      hash.each do |child_object_name, options|
        to_be_demetered << child_object_name
        inner_options = get_inner_options options
        eval_possible_default_option inner_options, child_object_name
        eval_possible_delegators inner_options, child_object_name
      end
    end

    def eval_possible_default_option options, child_object_name
      if options.include? :default
        raise TooManyDefaultsError unless self.demeter_default_child.nil?
        self.demeter_default_child = child_object_name
      end
    end

    def eval_possible_delegators options, child_object_name
      if has_delegators? options
        delegators = get_delegators options
        delegators[:delegate].each do |new_method_name, old_method_name|
          self.class_eval do
            full_new_name = child_object_name.to_s + '_' + new_method_name.to_s
            full_old_name = child_object_name.to_s + '_' + old_method_name.to_s
            define_method(full_new_name) do |*args|
              self.send *([full_old_name] + args)
            end
          end
        end
      end
    end

    def object_name_only? attr
      (not attr.respond_to? :values) or (not attr.respond_to? :keys)
    end

    def has_delegators? options
      not get_delegators(options).nil?
    end

    def get_delegators options
      delegators = options.find do |d|
        d.respond_to? :keys and not d[:delegate].nil?
      end 
    end

    def get_inner_options options
      if many_options? options
        options
      else
        [options]
      end
    end

    def many_options? option_value
      option_value.respond_to? :each
    end

    def demeter(*attrs)
      to_be_demetered = []
      attrs.each do |a|
        if object_name_only? a
          to_be_demetered << a 
        else
          eval_hash a, to_be_demetered
        end
      end
      self.demeter_names = to_be_demetered
      self.class_eval do
        demeter_names.each do |name|
          attr_accessor name
        end
      end
    end
  end
end

  # ActiveRecord support
  require "demeter/active_record"

  class TooManyDefaultsError < Exception
  end
