# frozen_string_literal: true

require 'active_model'
require 'active_record'

module HasEmbeddedDocument
  class Base
    include ActiveModel::Validations

    Attribute = Struct.new(:name, :type, :default)

    def self.inherited(subclass)
      super
      subclass.instance_variable_set(:@attributes, @attributes.dup)
    end

    # @return [Hash{Symbol => Attribute}]
    def self.attributes
      @attributes ||= {}
    end

    # @param name [Symbol]
    # @param type [Symbol]
    # @return [void]
    def self.attribute(name, type = :string, default: nil, **options)
      name = name.to_sym
      type = ActiveRecord::Type.lookup(type, **options)

      attributes[name] = Attribute.new(name, type, default).freeze

      define_method(name) { read_attribute(name) }
      define_method("#{name}=") { |value| write_attribute(name, value) }
    end

    # @param attributes [Hash{String => Object}]
    def initialize(attributes = {})
      @attributes = attributes.stringify_keys
    end

    # @return [Hash{Symbol => Object}]
    def attributes
      @attributes.dup
    end

    # @param attributes [Hash{Symbol => Object}]
    # @return [void]
    def attributes=(attributes)
      attributes.each do |name, value|
        write_attribute(name, value)
      end
    end

    # @return [Base]
    def dup
      self.class.new(attributes)
    end

    # @param attributes [Hash]
    # @return [Base]
    def dup_with(attributes)
      dup.tap do |object|
        object.attributes = attributes
      end
    end

    # @param name [Symbol]
    def read_attribute(name)
      attribute = self.class.attributes[name.to_sym]
      raise ArgumentError, "Unknown attribute: #{name}" if attribute.nil?

      @attributes.fetch(name.to_s) do
        case (default = attribute.default)
        when Proc   then instance_eval(&default)
        when Symbol then send(default)
        else default
        end
      end
    end

    # @param name [Symbol]
    # @param value [Object]
    # @return [void]
    def write_attribute(name, value)
      attribute = self.class.attributes[name.to_sym]
      raise ArgumentError, "Unknown attribute: #{name}" if attribute.nil?

      @attributes[name.to_s] = attribute.type.cast(value)
    end

    # @return [Boolean]
    def readonly?
      @attributes.frozen?
    end

    # @return [self]
    def readonly!
      tap { @attributes.freeze }
    end

    # @return [Hash]
    def to_h
      attributes
    end

    # @param other [Base]
    # @return [Boolean]
    def ==(other)
      other.is_a?(self.class) && other.attributes == @attributes
    end
  end
end
