<h1 align="center">
    <img src=".github/project-logo.svg" width="512px">
</h1>

# merkletree

Lightweight library that lets you create Merkle trees with custom branching factors.

The library supports all hashing algorithms native to V out of the box.

You can also use custom hashing algorithms that are implemented according to the interface.

```v
pub type HashFunction = fn (data []u8) []u8
```

## :bulb: Interface

```v
pub struct MerkleTree {
	branching_factor int = 2
	hash_function    HashFunction [required]
mut:
	root Node
}
```

### build

Builds Merkle tree structure and pre-computes hashes with given data blocks.

```v
pub fn (mut m MerkleTree) build(blocks [][]u8)
```

### get_root

Returns Merkle root of tree as byte array.

```v
pub fn (mut m MerkleTree) get_root() []u8
```

### HashFunction

In case you want to implement a custom hashing algorithm, please do so according to this blueprint.

```v
pub type HashFunction = fn (data []u8) []u8
```

## :rocket: Simple example

```v
import merkletree { MerkleTree }
import crypto.sha256

fn main() {
	mut tree := &MerkleTree{
		hash_function: sha256.sum
	}

	tree.build([
		'1'.bytes(),
		'2'.bytes(),
		'3'.bytes(),
		'4'.bytes(),
	])

	print(tree.get_root().hex())
}
```

## Feel like contributing?

Create an [issue](https://github.com/oa/merkletree/issues/new/choose) or a [pull request](https://github.com/oa/merkletree/compare).

## License

This project is licensed under the [MIT](LICENSE) license.
Feel free to do whatever you want with the code!
