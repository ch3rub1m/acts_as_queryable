# ActsAsQueryable

A Rails plugin to add support of Query by url search params.

This gem can be used to Query records without any scope.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'acts_as_queryable'
```

And then execute:

    $ bundle

## Usage

### In your model:

``` ruby
class Brand < ActiveRecord::Base
  acts_as_queryable

  # ...
end
```

Calling `query` with any attributes of the model will now get the filtered results:

``` ruby
>> Brand.all
=> #<ActiveRecord::Relation [#<V1::Brand id: 1, name: "Apple">,
                             #<V1::Brand id: 2, name: "Sony">,
                             #<V1::Brand id: 3, name: "Nintendo">,
                             #<V1::Brand id: 4, name: "Amazon">,
                             #<V1::Brand id: 5, name: nil>]>

>> Brand.query(name: 'Apple')
=> #<ActiveRecord::Relation [#<V1::Brand id: 1, name: "Apple">]>
```

If the type of attribute is `string`, the Query will use `contains` method.

``` ruby
>> Brand.query(name: 'So')
=> #<ActiveRecord::Relation [#<V1::Brand id: 2, name: "Sony">]>
```

#### Fetch the records that an attribute is NULL

``` ruby
>> Brand.query(name: 'NULL')
=> #<ActiveRecord::Relation [#<V1::Brand id: 5, name: nil>]>
```

#### Numeric comparison

If the type of attribute is `integer`, `float` or `datetime`, the Query will add numeric comparison support.

``` ruby
>> Brand.query(id_gt: 4)
=> #<ActiveRecord::Relation [#<V1::Brand id: 5, name: nil>]>

>> Brand.query(id_lt: 2)
=> #<ActiveRecord::Relation [#<V1::Brand id: 1, name: "Apple">]>
```

#### Multiple fetch

Multiple fetch is available by using a string split by comma(`,`) instead of a integer attribute.

``` ruby
>> Brand.query(id: '2,3')
=> #<ActiveRecord::Relation [#<V1::Brand id: 2, name: "Sony">, #<V1::Brand id: 3, name: "Nintendo">]>
```


### In your controller:

``` ruby
class BrandsController < ApplicationController
  def index
    @brands = Brand.query(params)

    # ...
  end
end
```

### Customize

#### excpet

If you don't want to use many attributes for Query , you can pass them as an option:

``` ruby
class Client < ActiveRecord::Base
  acts_as_queryable except: [:name]

  ...
end
```

#### order

If you want to open the `order` feature:

``` ruby
class Client < ActiveRecord::Base
  acts_as_queryable order: true

  ...
end
```

Now you can fetch the records order by an attribute:

`GET https://api.restful.com/v1/brands?order=id desc`

``` ruby
=> #<ActiveRecord::Relation [#<V1::Brand id: 5, name: nil>,
                             #<V1::Brand id: 4, name: "Amazon">,
                             #<V1::Brand id: 3, name: "Nintendo">,
                             #<V1::Brand id: 2, name: "Sony">,
                             #<V1::Brand id: 1, name: "Apple">]>
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ch3rub1m/acts_as_queryable. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
