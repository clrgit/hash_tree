
require 'hash_tree'

include HashTree

describe HashTree do
  it 'has a version number' do
    expect(HashTree::VERSION).not_to be_nil
  end

  describe HashTree::Set do
    let!(:root) { HashTree::Set.new(nil, "root") }
    let!(:lvl1) { HashTree::Set.new(root, "LVL1") }
    let!(:lvl2) { HashTree::Set.new(lvl1, "LVL2") }
    let!(:lvl3) { HashTree::Set.new(lvl2, "LVL3") }
    let!(:lvl4_1) { HashTree::Set.new(lvl3, "LVL4_1") }
    let!(:lvl4_2) { HashTree::Set.new(lvl3, "LVL4_2") }
    let!(:lvl4_3) { HashTree::Set.new(lvl3, "LVL4_3") }

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
    describe "#key" do
      it "is the unique key identifyin self within a parent" do
        expect(root.key).to eq "root"
      end
    end
    describe "#attach" do
      it "attaches a child node"
    end
    describe "#detach" do
      it "detaches a child node"
    end
    describe "#[]" do
      it "addresses a child node"
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
      it "returns a list of parents"
    end
    describe "#ancestors" do 
      it "returns a list of ancestors2"
    end
    describe "#path" do
      it "returns the object's path from the root element" do
        expect(root.path).to eq ""
        expect(lvl1.path).to eq "LVL1"
        expect(lvl4_3.path).to eq "LVL1.LVL2.LVL3.LVL4_3"
      end
    end
    describe "#dot" do
      it "looks up a path and return the matching node" do
        expect(root.dot("")).to be root
        expect(root.dot("LVL1")).to be lvl1
        expect(root.dot("LVL1.LVL2.LVL3.LVL4_3")).to be lvl4_3
      end
    end
    describe "#<=>" do
      it "compared two objects by path" do
        alt_root = HashTree::Set.new(nil, "root")
        alt_lvl1 = HashTree::Set.new(alt_root, "LVL1")
        alt_lvl2 = HashTree::Set.new(alt_lvl1, "LVL2")
        expect(alt_lvl2 <=> lvl2).to eq 0
        expect(lvl1 <=> lvl2).to eq -1
        expect(lvl3 <=> lvl2).to eq 1
      end
    end
    describe "#to_s" do
      it "renders its #key" do
        expect(lvl1.to_s).to eq lvl1.key.to_s
      end
    end
  end
end


