# frozen_string_literal: true

require 'rails/generators'

module HasEmbeddedDocument
  class DocumentGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('templates', __dir__)

    def create_document
      template 'document.rb.erb', "app/models/#{document_file_name}.rb"
    end

  private

    # @return [String]
    def document_class_name
      "#{name.camelize.chomp('Document')}Document"
    end

    # @return [String]
    def document_file_name
      document_class_name.underscore
    end
  end
end
