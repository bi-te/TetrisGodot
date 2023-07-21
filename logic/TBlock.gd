class_name TBlock extends Object

enum TYPE {I, J, L, O, S, T, Z, BNUM};

class BlockData extends Object:
	var size: Vector2i;
	var type: TYPE;
	var data: Array[bool];
	
	func _init(size_: Vector2i, type_: TYPE, data_: Array[bool]) -> void:
		size = size_;
		type = type_;
		data = data_;

static var all_blocks: Array[BlockData] = [
	BlockData.new(
		Vector2i(4, 4), TYPE.I,
		[
			0, 0, 0, 0,
			1, 1, 1, 1,
			0, 0, 0, 0,
			0, 0, 0, 0
		]
	),
	BlockData.new(
		Vector2i(3, 3), TYPE.J,
		[
			1, 0, 0,
			1, 1, 1,
			0, 0, 0,
		]
	),
	BlockData.new(
		Vector2i(3, 3), TYPE.L,
		[
			0, 0, 1,
			1, 1, 1,
			0, 0, 0,
		]
	),
	BlockData.new(
		Vector2i(2, 2), TYPE.O,
		[
			1, 1,
			1, 1,
		]
	),
	BlockData.new(
		Vector2i(3, 3), TYPE.S,
		[
			0, 1, 1,
			1, 1, 0,
			0, 0, 0,
		]
	),
	BlockData.new(
		Vector2i(3, 3), TYPE.T,
		[
			0, 1, 0,
			1, 1, 1,
			0, 0, 0,
		]
	),
	BlockData.new(
		Vector2i(3, 3), TYPE.Z,
		[
			1, 1, 0,
			0, 1, 1,
			0, 0, 0,
		]
	)
];

var state: int = -1;
var block: BlockData;
var position := Vector2i(0, 0);

func get_mino(x: int, y: int) -> bool:
	match (state):
		1:	return block.data[(block.size.y - 1 - x) * block.size.x + y];
		2:	return block.data[(block.size.y - 1 - y) * block.size.x + block.size.x  - 1 - x];
		3:	return block.data[x * block.size.x + block.size.x - 1 - y];
		_:	return block.data[y * block.size.x + x];
	
