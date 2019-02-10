# ActiveSerialize

Provide a very simple way to transform ActiveRecord data into Hash.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_serialize'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_serialize

## Basic Usage

There is a table `users`:
```ruby
t.string :name
t.string :email
```

And a table `books`:

```ruby
t.bigint :user_id
t.string :name
```

Declaration in model:
```ruby
class User < ActiveRecord::Base
  active_serialize
  has_many :books
  
  def love
    'Ruby'
  end
end

class Book < ActiveRecord::Base
  active_serialize rmv: :user_id
  belongs_to :user
end
```

Then:
```ruby
User.last.to_h
# => { "id" => 2, "name" => "ikkiuchi", "email" => "xxxx" }

User.where(id: [1, 2]).to_ha # means "to hash array"
# => [
#        { "id" => 1, "name" => "zhandao", "email" => "xxxx" },
#        { "id" => 2, "name" => "ikkiuchi", "email" => "xxxx" }
#    ]
```

The basic usage just looks like `attributes` method.

## How is it work?

ActiveRecord class method `column_names` (which is called by this gem) shows that the filed names by loading database schema.

## Advanced Usage

### Except (remove) keys

1. remove by default: `active_serialize rmv: [:email]` (you can also use `active_serialize_rmv`)
2. remove when calling `to_h`: `to_h(rmv: [:email])`

`=> { "id" => 2, "name" => "ikkiuchi" }`

### Add keys

1. add it by default: `active_serialize add: [:love]` (you can also use `active_serialize_add`)
2. add when calling `to_h`: `to_h(add: [:love])`

`=> { "id" => 2, "name" => "ikkiuchi", "email" => "xxxx", "love" => "Ruby" }`

* Values of addition keys will be the result of calling `public_send`

### Set default exception and addition keys

Using `active_serialize_default rmv: [ ], add: [ ]`

### Add recursive attributes

* recursive? —— calls `to_h` recursively (/ nested)

See below:
```ruby
User.first.books.to_ha
# => [{ "name" => "Rails Guide" }]

# declaration in User
active_serialize_add :books, recursive: true
# `active_serialize recursive: :books` is OK, but notice `active_serialize` should only be called once.

# then ...
User.first.to_h
# => { "id" => 2, "name" => "ikkiuchi", "email" => "xxxx", "books" => [{ "name" => "Rails Guide" }] }
```

### Add attributes only when passing the specified `group` key

Like the example below:

```ruby
User.active_serialize_add :love, group: :abcd
# Then:
User.first.to_h.keys.include?('love') # => false
User.first.to_h(:abcd).keys.include('love') # => true
```


### Transform key names

Choose one of the following ways:

1. `active_serialize_map love: :looove`
2. `active_serialize_add :love, named: :looove`

`=> { "id" => 2, "name" => "ikkiuchi", "email" => "xxxx", "looove" => "Ruby" }`

### Transform key format

1. set as default: `active_serialize_default key_format: ...`
2. only effect for a model: `active_serialize key_format: ...`

Optional value: `underscore / camelize / camelize_lower`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ikkiuchi/active_serialize. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ActiveSerialize project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ikkiuchi/active_serialize/blob/master/CODE_OF_CONDUCT.md).
