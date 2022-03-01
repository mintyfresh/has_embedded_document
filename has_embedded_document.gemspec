# frozen_string_literal: true

require_relative 'lib/has_embedded_document/version'

Gem::Specification.new do |spec|
  spec.name          = 'has_embedded_document'
  spec.version       = HasEmbeddedDocument::VERSION
  spec.authors       = ['Minty Fresh']
  spec.email         = ['7896757+mintyfresh@users.noreply.github.com']

  spec.summary       = 'Embedded data objects for ActiveRecord models'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/mintyfresh/has_embedded_document'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.6.0')

  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'activerecord', '>= 5.2.0'
end
