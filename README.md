# ClosureForwardable

[![Gem Version](https://badge.fury.io/rb/closure_forwardable.svg)](https://rubygems.org/gems/closure_forwardable)
[![Build Status](https://travis-ci.org/meineerde/closure_forwardable.svg?branch=master)](http://travis-ci.org/meineerde/closure_forwardable)

The `ClosureForwardable` module provides delegation of specified methods to a designated object, using the methods `delegate`, `def_delegator`, and `def_delegators`. It allows to define methods in a class or module which will be forwarded to any arbitrary object. This allows the user of this module to build meta-objects which provide a unified access to other objects which can be of great help when trying to adhere to the [Law of Demeter](https://en.wikipedia.org/wiki/Law_of_Demeter).

This module is intended to be used very similar to the [`Forwardable`](http://ruby-doc.org/stdlib-2.2.2/libdoc/forwardable/rdoc/Forwardable.html) module in the Ruby standard library. In fact, it provides almost the same interface and can be used in its place.

Generally, you should use the simple `Forwardable` module if possible as method calls will be slightly faster while providing the same functionality.

Use `ClosureForwardable` if you need to forward methods to a receiver that is not available by the including module itself. Using `ClosureForwardable`, you can forward methods to arbitrary objects.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'closure_forwardable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install closure_forwardable

## Usage

The `closure_forwardable` gem provides a single module called `ClosureForwardable`. You can use it to delegate methods on to arbitrary other objects.

In the following example, we are going to define two classes, `Consumer` and `Producer` whose instances share a single queue object.

```ruby
class Consumer
  extend ClosureForwardable

  def consume!
    return unless any?
    element = get_element
    puts element.inspect
    element
  end
end

class Producer
  extend ClosureForwardable
end

queue = []
# Add the methods any? to the Consumer class which simply calls any on our
# single queue object.
Consumer.def_delegator queue, :any?
# We also add a get_element method to the Consumer which in turn calls shift
# on the queue.
Consumer.def_delegator queue, :shift, :get_element

# Finally, we add the queue! method to the Producer class which calls the
# push method of the queue array.
Producer.def_delegator queue, :push, :queue!

producer = Producer.new
producer.queue! :job1
producer.queue! :job2

queue
# => [:job1, job2]

consumer = Consumer.new
consumer.consume!
# => job1
consumer.consume!
# => job2
consumer.consume!
# => nil

queue
# => []
```

Note that all instances of the classes share the same single `queue` object. Also note that the queue is not added in any way to the classes. There are no instance variables or accessors being defined on the classes. The queue is just made available to the delegation methods and is effectively invisible to the rest of the class.

This is the main difference to the `Forwardable` module of the Ruby standard library: for Forwardable to be able to delegate the methods, it needs to be able to ge access to the delegation object from
the class instance. Typically, this is achieved using accessors or instance variables. When using `ClosureForwardable`, this is no longer necessary as we can delegate methods to any arbitrary object.

## Why does this work?

The delegated object is in fact made available to the generated method. However, it is only visible though a block closure. With this mechanism which is provided by the block implementation of Ruby, when a block is executed, it can access all local variables which where available at the time the block was defined. This allows us to "hide" the delegation object inside a block's closure which forms the body of the method we define on our class.

Note that because of this, Ruby's garbage collector is intelligent enough to not destroy the object we delegate to as long as it is part of any block's closure. That means, when using `ClosureForwardable`, we strongly tie the forwarded object to the class. The delegation object will continue to be live as long as the class which delegates to it exists (thus typically forever).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/meineerde/closure_forwardable. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
