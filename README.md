# BuilderSupport

Provide a very simple way to transform ActiveRecord data into JSON output based on JBuilder.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'builder_support'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install builder_support

## Usage

Suppose the table `users`:
```ruby
t.string :name,            null: false
t.string :password_digest, null: false
t.string :email
```

Model:
```ruby
class User
  include BuilderSupport
  # YES, all you have to do is write this line
  builder_support rmv: %i[ password_digest ]
end
```

Console:
```
  $ User.all.to_builder # on records (active relation)
 => [
        { "id" => 1, "name" => "zhandao", "email" => "xxxx" },
        { "id" => 2, "name" => "ikkiuchi", "email" => "xxxx" }
    ]
  $ User.last.to_builder # on a record
 => { "id" => 2, "name" => "ikkiuchi", "email" => "xxxx" }
```

Explain:

1. Basic principle: the supporter know all the fields name through `column_names` (a db mapping func),
    so you just have to declare which fields do not need to output by passing 'rvm' param.
2. You can also `add` something to the output JSON, but make sure that the field name you add needs to correspond to the model instance methods.  
    The following example will generate `{ ..., "addtion_field" => "value' }`
    ```ruby
    class User
      builder_support add: :addition_field
      
      def addition_field
        'value'
      end
    end
    ```

## Advanced Usage

TODO

```ruby
builder_add :sub_categories_info, when: :get_nested_list
builder_add :base_category_info, name: :base_category, when: -> { base_category.present? }
builder_map a: :b
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/builder_support. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the BuilderSupport project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/builder_support/blob/master/CODE_OF_CONDUCT.md).
