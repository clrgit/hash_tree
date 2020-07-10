# HashTree

The `HashTree` module contains the Set and Map classes that implements a tree where each node acts as a hash over child nodes. `HashTree::Set` stores the key internally while `HashTree::Map` use an external key

`HashTree` is still work-in-progress

## Usage

Basic usage. Read the source for full(er) documentation

```ruby
require 'hash_tree'

class MyNode < HashTree::Set
  attr_reader :name
end

# Create a root node
root = MyNode.new(nil, "ROOT")

# Build hierarchy through constructor
child1 = MyNode.new(root, "CHILD1")
child11 = MyNode.new(child1, "CHILD11")

# Build hierarchy using #attach
child2 = MyNode.new(root, "CHILD2")
child1.attach(child12)

# Parent object
root.parent   # -> nil
child1.parent # -> root

# Lookup value
puts child1["CHILD1"] # -> "CHILD1"

# Check if key exists
child1.key?("CHILD11") # -> true
child1.key?("no key")  # -> false

# Get the root object
child11.root # -> root

# List of parents up to the root element
child11.parents # -> [child1, root]

# List of ancestors from the root down to parent
child11.ancestors # -> [root, child1]

# String of dot-separated keys leading from the root down to self
child11.path # -> "CHILD1.CHILD11"

# Recursively lookup element by string dot-separated keys
root.dot("CHILD1.CHILD11") -> child11
```

## Implementation

`HashTree` caches properties to avoid repetitive recursive lookups in `#parents`, `#ancestors` etc. The cache is reset every time a node is attached to or detached from a parent

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hash_tree'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hash_tree

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/clrgit/hash_tree.
