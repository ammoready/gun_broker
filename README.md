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

The full documentation is located here: http://www.rubydoc.info/github/ammoready/gun_broker

### Developer Token

You **must** set a developer key obtained from GunBroker.com in order to use this library.

```ruby
GunBroker.dev_key = 'your-sekret-dev-key'
```

### GunBroker::User

Authentication requires a `username` and an 'auth options' hash that requires **at least** a `password`
*or* `token`. If a password is given, you must call `User#authenticate!` to obtain an access token.

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

Once the User has an access token, you can then grab all of their items (listings).  All items methods
return an array of `GunBroker::Item` instances.

```ruby
user.items.all     # => [GunBroker::Item, ...]
user.items.unsold  # => [GunBroker::Item, ...]
user.items.sold    # => [GunBroker::Item, ...]
user.items.won     # => [GunBroker::Item, ...]
```

To revoke the access token, call `User#deauthenticate!`.  This method is also aliased as `#revoke_access_token!`.

```ruby
user.token  # => 'user-access-token'
user.deauthenticate!
user.token  # => nil
```

### GunBroker::Item

Represents an item (listing) on GunBroker.  The `Item#id` method returns the value of the `itemID` attribute
from the response.  All other attributes can be accessed through the `Item#[]` method.

```ruby
item.id  # => '1234567'
item['title']  # => 'Super Awesome Scope'
```

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

Much like GunBroker::Item, the `Category#id` method returns the `categoryID` attribute from the response.
All other attributes can be accessed with `Category#[]`.

```ruby
category.id  # => '123'
category['categoryName']  # => 'Firearms'
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
