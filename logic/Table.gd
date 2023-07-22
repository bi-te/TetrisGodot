class_name Table extends TileMap

signal game_over;
signal new_block(type: TBlock.TYPE);
signal hold_block(type: TBlock.TYPE);

const rows_offset: int = 2;
const table_rows: int = 22;
const table_columns: int = 10;
const table_rows_shown: int = 20;

var blocks_indices: Array[int] = [0, 1, 2, 3, 4, 5, 6];
var block_queue: Array[int];
var table: Array[TBlock.TYPE];
var current_block: TBlock;
var held_block := TBlock.TYPE.BNUM;
var input_state: InputState;
var on_hold: bool = false;

var game_state: GameState;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize();
	game_state = get_node("/root/TGameState");
	
	input_state = InputState.new();
	table.resize(table_rows * table_columns);
	table.fill(TBlock.TYPE.BNUM);
	current_block = TBlock.new();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_block.state == -1: return;
	input_state.check_input(delta);
	update_input();
	render();

func update_input() -> void:	
	if Input.is_action_just_pressed("drop_down"):
		current_block.position.y = find_future() + 1;
		check_finish();
		return;
	if Input.is_action_just_pressed("hold_piece") && !on_hold:
		on_hold = true;
		hold_current_block();
	
	current_block.position.x += input_state.hmove;
	if check_collision():
		current_block.position.x -= input_state.hmove;
	
	rotate_block();
	
	current_block.position.y += input_state.vmove;
	check_finish();

func render() -> void:
	var cell: TBlock.TYPE;
	for row in range(2, table_rows):
		for col in range(table_columns):
			cell = table[row * table_columns + col];
			if cell != TBlock.TYPE.BNUM:
				set_cell(0, Vector2i(col, row - rows_offset), 0, Vector2i(cell, 0));
			else:
				erase_cell(0, Vector2i(col, row - rows_offset));
	
	if current_block.state != -1:
		var future_pos := Vector2i(current_block.position.x, find_future()); 
		for row in range(current_block.block.size.x):
			if future_pos.y + row < 2: continue;
			for col in range(current_block.block.size.y):
				if current_block.get_mino(col, row):
					set_cell(0, future_pos + Vector2i(col, row - rows_offset),
							 0, Vector2i(current_block.block.type, 1), 0);
		
		for row in range(current_block.block.size.x):
			if current_block.position.y + row < 2: continue;
			for col in range(current_block.block.size.y):
				if current_block.get_mino(col, row):
					set_cell(0, current_block.position + Vector2i(col, row - rows_offset),
							 0, Vector2i(current_block.block.type, 0), 0);

func put_on_start(type: TBlock.TYPE) -> void:
	current_block.state = 0;
	current_block.block = TBlock.all_blocks[type];
	current_block.position.y = 0;
	if current_block.block.type == TBlock.TYPE.O \
	or current_block.block.type == TBlock.TYPE.I:
		current_block.position.x = 5 - current_block.block.size.x / 2;
	else:
		current_block.position.x = 4 - current_block.block.size.x / 2;

func spawn_block() -> void:
	if block_queue.size() <= 2:
		generate_next_blocks();
	
	put_on_start(block_queue.pop_front());
	
	if check_collision():
		current_block.state = -1;
		game_over.emit();
		
	new_block.emit(block_queue.front());

func rotate_block() -> void:
	current_block.state = (current_block.state + input_state.rotation) % 4;
	if check_collision():
		current_block.position.x += 1;
		if !check_collision(): return;
		current_block.position.x -= 2;
		if !check_collision(): return;
		if current_block.block.type == TBlock.TYPE.I:
			current_block.position.x += 3;
			if !check_collision(): return;
			current_block.position.x -= 4;
			if !check_collision(): return;
			current_block.position.x += 1;
		current_block.position.x += 1;
		current_block.state += 4 - input_state.rotation;

#returns true if collision detected
func check_collision() -> bool:
	if current_block.state == -1: return false;
	
	var cell_pos := Vector2i(0, 0);
	for row in range(current_block.block.size.x):
		for col in range(current_block.block.size.y):
			if current_block.get_mino(col, row):
				cell_pos.x = current_block.position.x + col;
				cell_pos.y = current_block.position.y + row;
				
				if cell_pos.x < 0 \
				|| cell_pos.x >= table_columns \
				|| cell_pos.y >= table_rows \
				|| table[cell_pos.y * table_columns + cell_pos.x] != TBlock.TYPE.BNUM:
					return true;
	return false;

func check_finish() -> void:
	if check_collision():
		current_block.position.y -= 1;
		on_hold = false;
		add_to_table();
		game_state.score_update(check_full_rows());
		spawn_block();

func add_to_table() -> void:
	var cell_pos := Vector2i(0, 0);
	for row in range(current_block.block.size.x):
		for col in range(current_block.block.size.y):
			if current_block.get_mino(col, row):
				cell_pos.x = current_block.position.x + col;
				cell_pos.y = current_block.position.y + row;
				table[cell_pos.y * table_columns + cell_pos.x] = current_block.block.type;

func check_full_rows() -> int:
	var full_rows: int = 0;
	for row in range(current_block.position.y + current_block.block.size.y - 1, 0, -1):
		if (row >= table_rows): continue;
		
		var is_full := true;
		var is_empty := true;
		for col in range(table_columns):
			if table[row * table_columns + col] == TBlock.TYPE.BNUM:
				is_full = false;
			else:
				is_empty = false;
			if not is_full && not is_empty:
				break;
		
		if is_full: 
			full_rows += 1; 
			continue;
		
		if is_empty: 
			for clear_row in range(full_rows):
				for col in range(table_columns):
					table[(row + clear_row + 1) * table_columns + col] = TBlock.TYPE.BNUM;
			break;
		
		if full_rows:
			for col in range(table_columns):
				table[(row + full_rows) * table_columns + col] = table[row * table_columns + col];
	
	return full_rows;

func reset() -> void:
	table.fill(TBlock.TYPE.BNUM);

func find_future() -> int:
	var cur_pos := current_block.position;
	current_block.position.y += 1;
	while !check_collision():
		current_block.position.y += 1;
	current_block.position.y -= 1;
	var future_row := current_block.position.y;
	current_block.position = cur_pos;
	return future_row;

func generate_next_blocks() -> void:
	blocks_indices.shuffle()
	block_queue.append_array(blocks_indices);

func hold_current_block() -> void:
	var temp := current_block.block.type;
	if held_block != TBlock.TYPE.BNUM:
		put_on_start(held_block);
		held_block = temp;
	else:
		held_block = current_block .block.type;
		spawn_block();
	hold_block.emit(temp);

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		current_block.free();
		input_state.free()
		

func _on_update_timer() -> void:
	current_block.position.y += 1;
	check_finish();
