# frozen_string_literal: true

module HasEmbeddedDocument
  module DSL
    # @param name [Symbol]
    # @param document_class [Class<HasEmbeddedDocument::Base>, String]
    # @param validate [Boolean]
    # @param optional [Boolean]
    # @return [void]
    def has_embedded_document(name, document_class, validate: true, optional: true) # rubocop:disable Naming/PredicateName
      define_embedded_reader(name, document_class)
      define_embedded_writer(name, document_class)

      validates(name, presence: { message: :required }) unless optional
      validate_embedded_document(name, **(validate.is_a?(Hash) ? validate : {})) if validate
    end

    # @param name [Symbol]
    # @param document_class [Class<HasEmbeddedDocument::Base>, String]
    # @param validate [Boolean]
    # @param optional [Boolean]
    # @return [void]
    def has_many_embedded_documents(name, document_class, validate: true, optional: true) # rubocop:disable Naming/PredicateName
      define_embedded_array_reader(name, document_class)
      define_embedded_array_writer(name, document_class)

      validates(name, presence: { message: :required }) unless optional
      validate_many_embedded_documents(name, **(validate.is_a?(Hash) ? validate : {})) if validate
    end

    # @param name [Symbol]
    # @return [void]
    def validate_embedded_document(name, **options)
      validate(**options) do
        document = send(name)

        if document&.invalid?
          document.errors.each do |error|
            errors.add("#{name}.#{error.attribute}", error.message)
          end
        end
      end
    end

    # @param name [Symbol]
    # @return [void]
    def validate_many_embedded_documents(name, **options)
      validate(**options) do
        documents = send(name)

        documents&.each_with_index do |document, index|
          next if document.valid?

          document.errors.each do |error|
            errors.add("#{name}[#{index}].#{error.attribute}", error.message)
          end
        end
      end
    end

    # @param document_class [Class, String]
    # @return [Class<HasEmbeddedDocument::Base>]
    def resolve_document_class(document_class)
      document_class = document_class.constantize if document_class.is_a?(String)
      raise ArgumentError, "Unknown document class: #{document_class}" unless document_class < HasEmbeddedDocument::Base

      document_class
    end

  private

    # @param name [Symbol]
    # @param document_class [Class<HasEmbeddedDocument::Base>, String]
    # @return [void]
    def define_embedded_reader(name, document_class)
      reader = wrapped_attribute_reader(name)

      define_method(name) do
        document_class = self.class.resolve_document_class(document_class)

        document = instance_variable_get(:"@__#{name}_cache")
        return document if instance_variable_defined?(:"@__#{name}_cache")

        attributes = reader.call(self)
        document   = attributes && document_class.new(attributes.dup).readonly!
        instance_variable_set(:"@__#{name}_cache", document)
      end
    end

    # @param name [Symbol]
    # @param document_class [Class<HasEmbeddedDocument::Base>, String]
    # @return [void]
    def define_embedded_writer(name, document_class)
      writer = wrapped_attribute_writer(name)

      define_method("#{name}=") do |value|
        document_class = self.class.resolve_document_class(document_class)

        attributes = value.is_a?(document_class) ? value.attributes : value
        writer.call(self, attributes)

        document = attributes && document_class.new(attributes.dup).readonly!
        instance_variable_set(:"@__#{name}_cache", document)
      end
    end

    # @param name [Symbol]
    # @param document_class [Class<HasEmbeddedDocument::Base>, String]
    # @return [void]
    def define_embedded_array_reader(name, document_class)
      reader = wrapped_attribute_reader(name)

      define_method(name) do
        document_class = self.class.resolve_document_class(document_class)

        documents = instance_variable_get(:"@__#{name}_cache")
        return documents if instance_variable_defined?(:"@__#{name}_cache")

        values    = reader.call(self)
        documents = values&.map { |attributes| document_class.new(attributes.dup).readonly! }
        instance_variable_set(:"@__#{name}_cache", documents)
      end
    end

    # @param name [Symbol]
    # @param document_class [Class<HasEmbeddedDocument::Base>, String]
    # @return [void]
    def define_embedded_array_writer(name, document_class)
      writer = wrapped_attribute_writer(name)

      define_method("#{name}=") do |values|
        document_class = self.class.resolve_document_class(document_class)

        values = values&.map { |value| value.is_a?(document_class) ? value.attributes : value }
        writer.call(self, values)

        documents = values&.map { |attributes| document_class.new(attributes.dup).readonly! }
        instance_variable_set(:"@__#{name}_cache", documents)
      end
    end

    # @param name [Symbol]
    # @return [Proc]
    def wrapped_attribute_reader(name)
      if respond_to?(:has_attribute?) && has_attribute?(name)
        -> (object) { object.read_attribute(name) }
      else
        wrapped_method = instance_method(name)
        -> (object) { wrapped_method.bind(object).call }
      end
    end

    # @param name [Symbol]
    # @return [Proc]
    def wrapped_attribute_writer(name)
      if respond_to?(:has_attribute?) && has_attribute?(name)
        -> (object, value) { object.write_attribute(name, value) }
      else
        wrapped_method = instance_method("#{name}=")
        -> (object, value) { wrapped_method.bind(object).call(value) }
      end
    end
  end
end
