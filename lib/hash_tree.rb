
require "indented_io"

# Simple tree of hashes
#
# TODO
#   o each
#   o traverse
#   o #ancestors and #parents as enumerators
#   o HashTree::Set, HashTree::Map, HashTree::Array
#   o Semantics of <=>: strictly partial so it returns nil on no common path?
#   o Drop <=> ?
#   o Implement #common to return common path of two elements
#   o modularize?
#   o []=
#
module HashTree
  class Error < StandardError; end

  # The base Node type for HashTree implementations. It is not supposed to be called
  # from user-code
  class Node
    # Parent node. nil for the root node
    attr_reader :parent

    # Hash from key to child node
    attr_reader :children

    def initialize(parent, key)
      @children = {}
      parent&.do_attach(key, self)
    end
    
    # Attach a child to self
    #
    # Implementation is in #do_attach to share code with HashTree::Set#attach
    # that only takes one parameters
    def attach(key, child) do_attach(key, child) end

    # Detach a child from self
    def detach(key, ignore_not_attached: false)
      @children.key?(key) or raise Error, "Non-existing child key: #{key.inspect}"
      child = children[key]
      ignore_not_attached || child.parent or raise Error, "Child is not attached"
      child.instance_variable_set(:@parent, nil)
      @children.delete(key)
      child.send(:clear_cached_properties)
    end

    # Lookup node by key
    def [](key) @children[key] end

    # Returns true iff key is included in children
    def key?(key) @children.key?(key) end

    # List of keys
    def keys() @children.keys end

    # List of values
    def values() @children.values end

    # The root object or self if parent is nil
    def root() @root ||= (parent&.root || self) end

    # List of parents up to the root element. If include_self is true, also
    # include self as the first element
    def parents(include_self = false)
      (include_self ? [self] : []) + (@parents ||= (parent&.parents(true) || []))
    end

    # List of parents from the root element down to parent. If include_self is
    # true, also include self as the last element
    def ancestors(include_self = false)
      (@ancestors ||= parents(false).reverse) + (include_self ? [self] : [])
    end

    # Recursively lookup object by dot-separated list of keys. Note that for
    # this to work, key names must not contain dot characters ('.')
    def dot(path_or_keys)
      keys = path_or_keys.is_a?(String) ? path_or_keys.split(".") : path_or_keys
      key = keys.shift or return self
      child = self[key] or raise "Can't lookup '#{key}' in #{self.path.inspect}"
      child.send(:dot, keys)
    end

    # List of [key, child] tuples
    def each(&block)
      if block_given?
        children.each { |key, child| yield(key, child) }
      else
        children.each
      end
    end

    # List of child nodes
    def each_child(&block)
      if block_given?
        children.values.each { |child| yield(child) }
      else
        children.values.each
      end
    end

    # :include => emit node and continue to children
    # :fetch => emit node but skip children
    # :exclude => skip node and continue to children
    # :prune => skip node and children
    #def filter(...)
    #end

  protected
    # Attach a child node to self
    def do_attach(key, child)
      !@children.key?(key) or raise Error, "Duplicate child key: #{key.inspect}"
      !child.parent or raise Error, "Child is already attached"
      child.instance_variable_set(:@parent, self)
      @children[key] = child
      child.send(:clear_cached_properties)
    end

  private
    # Recursively clear cached properties like @parents in each node in the
    # tree. Should be called whenever the node is attached or detached from a
    # tree
    #
    # Note that to speed up the process, it stops recursing when a node has no
    # cached properties. This is using the fact that the cached properties are
    # themselves constructed recursively so that iff a node has a cached
    # property, then all its parents will also cache it
    def clear_cached_properties()
      if@root || @parents || @ancestors || @path
        @root = nil
        @parents = nil
        @ancestors = nil
        @path = nil
        children.values.each { |c| c.clear_cached_properties }
      end
    end
  end

  class Set < Node
    alias node_attach attach

    # Key of this node. 
    # TODO: Make it possible/required to alias this method to provide an internal key
    attr_reader :key

    def initialize(parent, key)
      super(parent, @key = key)
    end

    def attach(child) do_attach(child.key, child) end

    def retach(node)
      node.parent.detach(node.key)
      attach(node)
    end

    # Unique dot-separated list of keys leading from the root object to 
    # self. Note that the root object is not included in the path so that
    #
    #   obj.parent.nil? || obj.root.dot(obj.path) == obj
    #
    # is always true
    #
    # Note that for this to work, keys may not contain a dots ('.')
    def path() @path ||= ancestors(true)[1..-1].join(".") end

    # A set node is rendered as its key
    def to_s() key.to_s end
  end

  class Map < Node
    # A map node is rendered as its object_id
    def to_s() object_id.to_s end
  end
end


