
require 'hash_tree'

include HashTree

shared_examples_for "a HashTree::Node" do |klass|
  # root
  let!(:root) { klass.new(nil, "root") }
  let!(:lvl1_1) { klass.new(root, "LVL1_1") }
  let!(:lvl1_2) { klass.new(root, "LVL1_2") }
  let!(:lvl2) { klass.new(lvl1_1, "LVL2") }
  let!(:lvl3) { klass.new(lvl2, "LVL3") }
  let!(:lvl4_1) { klass.new(lvl3, "LVL4_1") }
  let!(:lvl4_2) { klass.new(lvl3, "LVL4_2") }
  let!(:lvl4_3) { klass.new(lvl3, "LVL4_3") }

  describe "#parent" do
    it "reference the parent" do
      expect(lvl1_1.parent).to be root
    end

    it "is null for the root element" do
      expect(root.parent).to be nil
    end
  end

  describe "#children" do
    it "is a hash from key to node" do
      expect(lvl3.children).to eq({
        "LVL4_1" => lvl4_1,
        "LVL4_2" => lvl4_2,
        "LVL4_3" => lvl4_3
      })
    end
  end

  describe "#attach" do
    it "attaches a child node"
    it "raises an Error on duplicate keys"
  end

  describe "#detach" do
    it "detaches a child node"
    it "raises an Error on non-existing child"
    it "ignores non-existing children if :ignore_not_attached is true"
  end

  describe "#[]" do
    it "addresses a child node"
    it "returns nil if the key is not found"
  end

  describe "#key?" do
    it "returns true iff key identifies a child"
  end

  describe "#keys" do
    it "returns a list of keys" do
      expect(lvl3.keys).to eq %w(LVL4_1 LVL4_2 LVL4_3)
    end
  end

  describe "#root" do
    it "returns the root element or self if parent is nil" do
      expect(root.root).to be root
      expect(lvl4_3.root).to be root
    end
  end

  describe "#parents" do
    it "returns a list of parents" do
      expect(root.parents).to eq []
      expect(root.parents(true)).to eq [root]
      expect(lvl4_3.parents).to eq [lvl3, lvl2, lvl1_1, root]
      expect(lvl4_3.parents (true)).to eq [lvl4_3, lvl3, lvl2, lvl1_1, root]
    end
  end

  describe "#ancestors" do 
    it "returns a list of ancestors" do
      expect(root.ancestors).to eq []
      expect(root.ancestors(true)).to eq [root]
      expect(lvl4_3.ancestors).to eq [root, lvl1_1, lvl2, lvl3]
      expect(lvl4_3.ancestors (true)).to eq [root, lvl1_1, lvl2, lvl3, lvl4_3]
    end
  end

  describe "#each" do
    context "with a block" do
      it "executes the block for each key-child pair" do
        result = []
        lvl3.each { |key, node| result << [key, node] }
        expect(result).to eq [["LVL4_1", lvl4_1], ["LVL4_2", lvl4_2], ["LVL4_3", lvl4_3]]
      end
    end
    context "without a block" do
      it "returns an enumerator of the child nodes" do
        val = lvl3.each
        expect(val).to be_a Enumerator
        expect(val.to_a).to eq [["LVL4_1", lvl4_1], ["LVL4_2", lvl4_2], ["LVL4_3", lvl4_3]]
      end
    end
  end

  describe "#preorder" do
    it "returns the nodes in preorder" do
      expected = [root, lvl1_1, lvl2, lvl3, lvl4_1, lvl4_2, lvl4_3, lvl1_2]
      expect(root.preorder).to eq expected
    end
  end

  describe "#postorder" do
    it "returns the nodes in postorder" do
      expected = [lvl4_1, lvl4_2, lvl4_3, lvl3, lvl2, lvl1_1, lvl1_2, root]
      expect(root.postorder).to eq expected
    end
  end

  describe "#dot" do
    it "looks up a path and return the matching node" do
      expect(root.dot("")).to be root
      expect(root.dot("LVL1_1")).to be lvl1_1
      expect(root.dot("LVL1_1.LVL2.LVL3.LVL4_3")).to be lvl4_3
    end
  end
end

describe HashTree do
  it 'has a version number' do
    expect(HashTree::VERSION).not_to be_nil
  end

  describe HashTree::Set do
    it_should_behave_like "a HashTree::Node", HashTree::Set

    let!(:root) { HashTree::Set.new(nil, "root") }
    let!(:lvl1_1) { HashTree::Set.new(root, "LVL1_1") }
    let!(:lvl2) { HashTree::Set.new(lvl1_1, "LVL2") }
    let!(:lvl3) { HashTree::Set.new(lvl2, "LVL3") }

    describe "#key" do
      it "is the unique key identifying self within a parent" do
        expect(root.key).to eq "root"
      end
    end

    describe "#retach" do
      it "moves the node from its current parent to self" do
        root.retach(lvl2)
        expect(lvl2.parent).to be root
        expect(root.children.values).to eq [lvl1_1, lvl2]
        expect(lvl1_1.children.values).to eq []
      end
    end

    describe "#path" do
      it "returns the object's path from the root element" do
        expect(root.path).to eq ""
        expect(lvl1_1.path).to eq "LVL1_1"
        expect(lvl3.path).to eq "LVL1_1.LVL2.LVL3"
      end
    end

    describe "#to_s" do
      it "renders its #key" do
        expect(lvl1_1.to_s).to eq lvl1_1.key.to_s
      end
    end
  end

  describe HashTree::Map do
    it_should_behave_like "a HashTree::Node", HashTree::Map

    let!(:root) { HashTree::Map.new(nil, "root") }
    let!(:lvl1_1) { HashTree::Map.new(root, "LVL1_1") }

    describe "#to_s" do
      it "renders its object_id" do
        expect(lvl1_1.to_s).to eq lvl1_1.object_id.to_s
      end
    end
  end
end
