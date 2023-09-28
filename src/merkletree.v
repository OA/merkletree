module merkletree

pub type HashFunction = fn (data []u8) []u8

pub struct MerkleTree {
	branching_factor int = 2
	hash_function    HashFunction [required]
mut:
	root Node
}

struct Node {
	children []&Child [required] = []
mut:
	hash []u8 = []u8{}
}

struct Block {
	value []u8 [required]
}

type Child = Block | Node

[inline]
pub fn (mut m MerkleTree) build(blocks [][]u8) {
	mut leaves := []&Child{}

	// create leaf nodes
	for block in blocks {
		leaves << &Node{
			children: [Block{
				value: block
			}]
		}
	}

	m.process_nodes(leaves)
}

[inline]
fn (mut m MerkleTree) process_nodes(nodes []&Child) {
	if 1 == nodes.len {
		// root found
		m.root = nodes[0] as Node
		return
	}

	mut parents := []&Child{}

	// only create parent node from every m.branching_factor-th node and its siblings
	for i := 0; i <= nodes.len - 1; i += m.branching_factor {
		mut siblings := []&Child{}

		// group nodes dependent on branching factor
		for j := i; j < i + m.branching_factor; j++ {
			// are there enough nodes to fill this group of siblings?
			if j < nodes.len {
				siblings << nodes[j]
			}
		}

		// do not add layers to lonely nodes
		if 1 == siblings.len {
			parents << siblings
		} else {
			parents << &Node{
				children: siblings
			}
		}
	}

	m.process_nodes(parents)
}

[inline]
fn (mut n Node) get_hash(hash_function HashFunction) []u8 {
	mut payload := []u8{}

	if 1 == n.children.len {
		// is this a leaf or a lonely node?
		if n.children[0] is Node {
			// lonely node -> avoid re-hashing
			mut child := &(n.children[0] as Node)
			return child.get_hash(hash_function)
		}

		// prevent second preimage attacks
		payload << 0
		payload << (n.children[0] as Block).value
	} else {
		// prevent second preimage attacks
		payload << 1

		// create sum of child nodes
		for child in n.children {
			mut casted := &(child as Node)
			payload << casted.get_hash(hash_function)
		}
	}

	return hash_function(payload)
}

[inline]
pub fn (mut m MerkleTree) get_root() []u8 {
	return m.root.get_hash(m.hash_function)
}
