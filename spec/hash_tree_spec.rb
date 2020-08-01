
require 'hash_tree'

include HashTree

shared_examples_for "a HashTree::Node" do |klass|
  let!(:root) { klass.new(nil, "root") }
  let!(:lvl1) { klass.new(root, "LVL1") }
  let!(:lvl2) { klass.new(lvl1, "LVL2") }
  let!(:lvl3) { klass.new(lvl2, "LVL3") }
  let!(:lvl4_1) { klass.new(lvl3, "LVL4_1") }
  let!(:lvl4_2) { klass.new(lvl3, "LVL4_2") }
  let!(:lvl4_3) { klass.new(lvl3, "LVL4_3") }

  describe "#parent" do
    it "reference the parent" do
      expect(lvl1.parent).to be root
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
      expect(lvl4_3.parents).to eq [lvl3, lvl2, lvl1, root]
      expect(lvl4_3.parents (true)).to eq [lvl4_3, lvl3, lvl2, lvl1, root]
    end
  end

  describe "#ancestors" do 
    it "returns a list of ancestors" do
      expect(root.ancestors).to eq []
      expect(root.ancestors(true)).to eq [root]
      expect(lvl4_3.ancestors).to eq [root, lvl1, lvl2, lvl3]
      expect(lvl4_3.ancestors (true)).to eq [root, lvl1, lvl2, lvl3, lvl4_3]
    end
  end

  describe "#dot" do
    it "looks up a path and return the matching node" do
      expect(root.dot("")).to be root
      expect(root.dot("LVL1")).to be lvl1
      expect(root.dot("LVL1.LVL2.LVL3.LVL4_3")).to be lvl4_3
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
    let!(:lvl1) { HashTree::Set.new(root, "LVL1") }
    let!(:lvl2) { HashTree::Set.new(lvl1, "LVL2") }
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
        expect(root.children.values).to eq [lvl1, lvl2]
        expect(lvl1.children.values).to eq []
      end
    end

    describe "#path" do
      it "returns the object's path from the root element" do
        expect(root.path).to eq ""
        expect(lvl1.path).to eq "LVL1"
        expect(lvl3.path).to eq "LVL1.LVL2.LVL3"
      end
    end

    describe "#to_s" do
      it "renders its #key" do
        expect(lvl1.to_s).to eq lvl1.key.to_s
      end
    end
  end

  describe HashTree::Map do
    it_should_behave_like "a HashTree::Node", HashTree::Map

    let!(:root) { HashTree::Map.new(nil, "root") }
    let!(:lvl1) { HashTree::Map.new(root, "LVL1") }

    describe "#to_s" do
      it "renders its object_id" do
        expect(lvl1.to_s).to eq lvl1.object_id.to_s
      end
    end
  end
end
