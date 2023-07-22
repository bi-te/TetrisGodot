class_name HUD extends CanvasLayer

var next_tilemap: TileMap;
var hold_tilemap: TileMap;
var score_label: Label;
var level_label: Label;

func _ready() -> void:
	next_tilemap = $Next/TileMap;
	hold_tilemap = $Hold/TileMap;
	score_label = $Score/ScoreNum;
	level_label = $Level/LevelNum;

func _on_score_update(score: int) -> void:
	score_label.text = var_to_str(score);

func _on_level_update(level: int) -> void:
	level_label.text = var_to_str(level);

func _on_next_block_changed(type: TBlock.TYPE) -> void:
	var block_to_show: TBlock.BlockData = TBlock.all_blocks[type];
	next_tilemap.clear_layer(0);
	next_tilemap.position = Vector2(16, 16) * (5 - block_to_show.size.x);
	for row in range(block_to_show.size.x):
		for col in range(block_to_show.size.y):
			if block_to_show.data[row * block_to_show.size.x + col]:
				next_tilemap.set_cell(0, Vector2i(col, row), 0, Vector2i(type, 0), 0);


func _on_hold_block_changed(type: TBlock.TYPE) -> void:
	var block_to_show: TBlock.BlockData = TBlock.all_blocks[type];
	hold_tilemap.clear_layer(0);
	hold_tilemap.position = Vector2(16, 16) * (5 - block_to_show.size.x);
	for row in range(block_to_show.size.x):
		for col in range(block_to_show.size.y):
			if block_to_show.data[row * block_to_show.size.x + col]:
				hold_tilemap.set_cell(0, Vector2i(col, row), 0, Vector2i(type, 0), 0);
