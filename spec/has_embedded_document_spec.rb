# frozen_string_literal: true

RSpec.describe HasEmbeddedDocument do
  it 'has a version number' do
    expect(HasEmbeddedDocument::VERSION).not_to be nil
  end
end
