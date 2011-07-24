require File.expand_path("demeter/demeter_options/demeter_options_dispatcher", File.dirname(__FILE__))

module Demeter
  def self.extended(base)
    base.class_eval do
      include InstanceMethods
      extend ClassMethods

      class << self
        attr_accessor :demeter_names, :default_name, :nil_block
      end

      base.demeter_names = []
    end
  end

  module InstanceMethods

    def method_missing_proc method_name, *attrs, &block
      object_method_name = method_name.to_s

      object_name = self.class.demeter_names.find do |name| 
        object_method_name =~ /^#{name}_/ 
      end

      child = self.class.default_name

      if object_name.nil? and child.nil?
        false
      elsif object_name.nil?
        child_object = self.send child
        if child_object.nil?
          message = 'Default object is nil. It must be non-nil for default ' +
            'to work correctly.'
          raise DefaultObjectIsNilError.new message
        elsif child_object.respond_to? method_name
            lambda {child_object.send method_name, *attrs, &block}
        else
          false
        end
      else
          object_method_name.gsub!(/^#{object_name}_/, "")
          target  = self.send object_name
          if target.nil?
            lambda {nil}
          else
            lambda do 
            target.send object_method_name, *attrs, &block
            end
        end
      end
    end
    def method_missing(method_name, *attrs, &block)
      result = method_missing_proc(method_name, *attrs, &block)
      if result
        result.call
      else
        super
      end
    end

    def respond_to?(method_name, include_private = false)
      super || !! method_missing_proc(method_name)
    end
  end

  module ClassMethods
    def demeter *attrs, &block
      dispatcher = DemeterOptionsDispatcher.new self
      dispatcher.dispatch! *attrs, &block

      self.demeter_names = dispatcher.to_be_demetered
      self.default_name = dispatcher.default_name
      self.class_eval do
        demeter_names.each do |name|
          attr_accessor name
        end
      end
    end
  end
end

class DefaultObjectIsNilError < RuntimeError
end
# ActiveRecord support
require "demeter/active_record"
