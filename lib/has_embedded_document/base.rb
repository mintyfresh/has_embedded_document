# frozen_string_literal: true

require 'active_model'
require 'active_record'

module HasEmbeddedDocument
  class Base
    include ActiveModel::Validations

    Attribute = Struct.new(:name, :type, :default)

    # @return [Hash{Symbol => Attribute}]
    def self.attributes
      @attributes ||= {}
    end

    # @param name [Symbol]
    # @param type [Symbol]
    # @return [void]
    def self.attribute(name, type = :string, default: nil, **options)
      name = name.to_sym
      type = ActiveModel::Type.lookup(type, **options)

      attributes[name] = Attribute.new(name, type, default).freeze

      define_method(name) { read_attribute(name) }
      define_method("#{name}=") { |value| write_attribute(name, value) }
    end

    # @param parent [Object]
    def initialize(parent, store_name)
      @parent     = parent
      @store_name = store_name
    end

    # @return [Hash{Symbol => Object}]
    def attributes
      self.class.attributes.transform_values { |attribute| read_attribute(attribute.name) }
    end

    # @param attributes [Hash{Symbol => Object}]
    # @return [void]
    def attributes=(attributes)
      attributes.each do |name, value|
        write_attribute(name, value)
      end
    end

    # @param name [Symbol]
    def read_attribute(name)
      attribute = self.class.attributes[name.to_sym]
      raise ArgumentError, "Unknown attribute: #{name}" if attribute.nil?

      @parent.send(@store_name).fetch(name.to_s) do
        attribute.default
      end
    end

    # @param name [Symbol]
    # @param value [Object]
    # @return [void]
    def write_attribute(name, value)
      attribute = self.class.attributes[name.to_sym]
      raise ArgumentError, "Unknown attribute: #{name}" if attribute.nil?

      @parent.send(@store_name)[name.to_s] = attribute.type.cast(value)
    end
  end
end
