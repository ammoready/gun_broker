# GunBroker

GunBroker.com API Ruby library.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gun_broker'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gun_broker

## Usage

### Documentation

The full documentation is located here: http://www.rubydoc.info/gems/gun_broker

### Developer Token

You **must** set a developer key obtained from GunBroker.com in order to use this library.

```ruby
GunBroker.dev_key = 'your-sekret-dev-key'
```

### GunBroker::User

#### Authentication

Authentication requires a `username` and an 'auth options' hash that requires **at least** a `:password`
*or* `:token`. If a password is given, you must call `User#authenticate!` to obtain an access token.

```ruby
# By username/password:
user = GunBroker::User.new('username', password: 'sekret-password')
user.authenticate!
user.token  # => 'user-access-token'

# Or with an existing Access Token:
user = GunBroker::User.new('username', token: 'user-access-token')
# No need to call #authenticate! since we already have an access token.
user.token  # => 'user-access-token'
```

To revoke the access token, call `User#deauthenticate!`.  This method is also aliased as `#revoke_access_token!`.

```ruby
user.token  # => 'user-access-token'
user.deauthenticate!
user.token  # => nil
```

#### Items

You can access a User's Items through the `User#items` method, which returns an instance of `User::ItemsDelegate`.

```ruby
user.items.all   # => [GunBroker::Item, ...]
user.items.sold  # => [GunBroker::Item, ...]
```

To find a specific Item by its ID, use `#find`. This will return a `GunBroker::Item` instance or `nil` if no item found.

```ruby
item = user.items.find(123)
```

To raise a `GunBroker::Error::NotFound` exception if no Item can be found, use `#find!`.


### GunBroker::Item

Represents an item (listing) on GunBroker.  The `Item#id` method returns the value of the `itemID` attribute
from the response.  All other attributes can be accessed through the `Item#[]` method.

```ruby
item.id  # => '1234567'
item.title  # => 'Super Awesome Scope'
item.category  # => GunBroker::Category
item['description']  # => 'This scope is really awesome.'
```

You can find an Item belonging to the authenticated User with `user.items.find` or any Item with `Item.find`.

```ruby
# Returns the Item or nil, if the User has no Item with that ID.
user.items.find(123)

# Find any Item by its ID.
GunBroker::Item.find(123)
```

To raise a `GunBroker::Error::NotFound` exception if no Item can be found, use `Item.find!`.


### GunBroker::Category

Returns GunBroker category responses.  To get an array of all categories, call `Category#all()`.

```ruby
GunBroker::Category.all
# => [GunBroker::Category, ...]
```

You can also pass an optional parent category ID, to only return subcategories of the given parent.
For example, if the 'Firearms' category has an ID of '123', get all Firearm subcategories like this:

```ruby
firearms = '123'  # ID of the Firearms Category
GunBroker::Category.all(firearms)
# => [GunBroker::Category, ...]
```

To find a Category by a specific ID, use either `Category.find` or `Category.find!`.

```ruby
GunBroker::Category.find(123)
# => Returns the Category or nil
GunBroker::Category.find!(123)
# => Returns the Category or raises GunBroker::Error::NotFound
```

Much like GunBroker::Item, the `Category#id` method returns the `categoryID` attribute from the response.
All other attributes can be accessed with `Category#[]`.

```ruby
category.id  # => '123'
category.name  # => 'Firearms'
category['description']  # => 'Modern Firearms are defined ...'
```

### GunBroker::API

If you need to access an API endpoint not yet supported, you can use `GunBroker::API` directly.  Currently
supported HTTP methods are `GET`, `DELETE`, and `POST`, with each having a corresponding method on the
`GunBroker::API` class.

Each method requires a `path` and accepts optional `params` and `headers` hashes.  If making a `GET` request,
the `params` will be URL params; if making a `POST` request, the `params` will be turned into JSON and set
as the request body.

You can also set HTTP headers by passing a hash as the third argument.  Headers will **always** contain:

* `Content-Type: application/json`
* `X-DevKey: your-sekret-dev-key`

The response will be parsed JSON (hash).

```ruby
GunBroker::API.get('/some/resource')
# => { 'name' => 'resource', 'foo' => 'bar' }

GunBroker::API.post('/some/resource', { name: 'some data' })

# No params, but some headers:
GunBroker::API.delete('/some/resource', {}, { 'X-TestHeader' => 'FooBar' })
```

### Error Handling

Methods that require authorization (with an access token) will raise a `GunBroker::Error::NotAuthorized`
exception if the token isn't valid.  Otherwise, if there is some other issue with the request (namely,
the response status code is not in the `2xx` range), a `GunBroker::Error::RequestError` will be raised.

## Contributing

1. Fork it ( https://github.com/ammoready/gun_broker/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
