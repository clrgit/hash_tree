
require "indented_io"

# Simple tree of hashes
#
# TODO
#   o each
#   o traverse
#   o #ancestors and #parents as enumerators
#   o HashTree::Set, HashTree::Map, HashTree::Array
#
module HashTree
  class Node
    attr_reader :parent
    attr_reader :children

    def initialize(parent, key)
      @children = {}
      parent&.do_attach(key, self)
    end
    
    def attach(key, child) do_attach(key, child) end

    def detach(key, ignore_not_attached: false)
      @children.key?(key) or raise "Non-existing child key: #{key.inspect}"
      child = children[key]
      ignore_not_attached || child.parent or raise "Child is not attached"
      child.instance_variable_set(:@parent, nil)
      @children.delete(key)
      child.send(:clear_cached_properties)
    end

    def [](key) @children[key] end
    def key?(key) @children.key?(key) end

    # The root object or self if parent is nil
    def root() @root ||= parents.last || self end

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

    # Recursively lookup object by dot-separated list of names
    #
    # Note that for this to work, keys may not contain a dots ('.')
    def dot(path)
      path.split(".").inject(self) { |a,e| a[e] or raise "Can't lookup '#{e}' in #{a.path.inspect}" }
    end

  protected
    def do_attach(key, child)
      !@children.key?(key) or raise "Duplicate child key: #{key.inspect}"
      !child.parent or raise "Child is already attached"
      child.instance_variable_set(:@parent, self)
      @children[key] = child
      child.send(:clear_cached_properties)
    end

  private
    # Recursively clear cached properties like @parents in each node in the
    # tree. Should be called whenever the node is attached or detached from a
    # tree
    #
    # Note that to speed up the process, it stop recursion when a node has no
    # cached properties. This is using the fact that the cached properties are
    # themselves constructed recursively so that if a node has a cached
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

    attr_reader :key

    def initialize(parent, key)
      @key = key
      super(parent, key)
    end

    def attach(child) do_attach(child.key, child) end

    # Unique dot-separated list of keys leading from the root object to 
    # self. Note that the root object is not included in the path so that
    #
    #   obj.parent.nil? || obj.root.dot(obj.path) == obj
    #
    # is always true
    #
    # Note that for this to work, keys may not contain a dots ('.')
    def path() @path ||= ancestors(true)[1..-1].join(".") end

    # Compare two objects by path
    def <=>(r) path <=> r.path end

    # A set node is rendered as its key
    def to_s() key.to_s end
  end

  class Map < Node
    def <=>(r) raise NotImplementedError; end

    # A map node is rendered as its object_id
    def to_s() object_id.to_s end
  end
end


