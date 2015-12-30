# Attention

[![Build Status](https://travis-ci.org/parrish/Attention.svg?branch=master)](https://travis-ci.org/parrish/Attention)
[![Test Coverage](https://codeclimate.com/github/parrish/Attention/badges/coverage.svg)](https://codeclimate.com/github/parrish/Attention)
[![Code Climate](https://codeclimate.com/github/parrish/Attention/badges/gpa.svg)](https://codeclimate.com/github/parrish/Attention)
[![Gem Version](https://badge.fury.io/rb/attention.svg)](http://badge.fury.io/rb/attention)

Redis-based server awareness for distributed applications

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'attention'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install attention

## Usage

Activate the instance:
```ruby
# Autodiscover the ip and exclude the port
Attention.activate

# Or specify them explicitly
Attention.activate ip: '1.2.3.4', port: 9000
```

The current instance is accessible at:
```ruby
Attention.instance
```

Deactivate the instance:
```ruby
Attention.deactivate
```

Subscribe to instance availability changes:
```ruby
Attention.on_change do |change, instances|
  # This block is asynchronously called on each change
end
```

Or get the list of available instances:
```ruby
Attention.instances
```

## Configuration

Options can be set on `Attention.options`

```ruby
Attention.options = {
  namespace: 'attention',                # Redis key namespace
  ttl: 60,                               # Instance heartbeat TTL in seconds
  redis_url: 'redis://localhost:6379/0', # Redis connection string
  pool_size: 5,                          # Size of the publishing Redis connection pool
  timeout: 5                             # Redis connection timeout
}
```

## Notes

The top-level API provides a simple way to keep track of instance availability.  More complex schemes of communication could be implemented by using the [`Subscriber`](http://www.rubydoc.info/github/parrish/attention/master/Attention/Subscriber) and [`Publisher`](http://www.rubydoc.info/github/parrish/attention/master/Attention/Publisher) classes directly.

Instances attempt to deactivate themselves when the program terminates(`at_exit`).  If the instance crashes in a dramatic fashion (or a `kill -9`), the instance will continue to be listed as available until the TTL (`Attention.options[:ttl]`) expires.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/parrish/attention. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
