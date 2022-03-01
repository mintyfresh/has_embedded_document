# HasEmbeddedDocument

Embedded JSON document objects for your ActiveRecord models.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'has_embedded_document'
```

And then execute:

    $ bundle install

Then run:

    $ bin/rails has_embedded_document:install

### Installing the DSL

Add to your application record class:

```ruby
class ApplicationRecord < ActiveRecord::Base
  extend HasEmbeddedDocument::DSL

  # ...
end
```

## Usage

```ruby
class Address < ApplicationDocument
  attribute :line1, :string
  attribute :city, :string
  attribute :region, :string
  attribute :country, :string
end
```

```ruby
class User < ApplicationRecord
  has_embedded_document :address, Address
end
```

```ruby
user = User.new
user.address = Address.new(country: 'CA', region: 'ON')

user.address.country # => 'CA'
user.address.region  # => 'ON'
```

### Validations

```ruby
class Address < ApplicationDocument
  attribute :line1, :string
  attribute :city, :string
  attribute :region, :string
  attribute :country, :string

  validates :line1, :city, :region, presence: true
  validates :country, inclusion: { in: ['CA', 'US'] }
end
```

```ruby
user = User.new
user.address = Address.new(country: 'CA', region: 'ON', city: 'Toronto')

user.valid? # => false
user.errors # => address.line1 can't be blank, etc.
```

### Disable Validations

```ruby
class User < ApplicationRecord
  has_embedded_document :address, Address, validate: false
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mintyfresh/has_embedded_document.
