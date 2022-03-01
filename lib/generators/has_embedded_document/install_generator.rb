# frozen_string_literal: true

require 'rails/generators'

module HasEmbeddedDocument
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def create_install
      template 'application_document.rb', 'app/models/application_document.rb'
    end
  end
end
