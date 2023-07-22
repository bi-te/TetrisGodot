extends Node2D

var table: Table;
var fall_timer: Timer;
var hud: HUD;

var game_status: bool = false;
var game_state: GameState;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	table = $Table as Table;
	fall_timer = $UpdateTimer;
	hud = $HUD;
	
	table.game_over.connect(_on_game_over);
	table.spawn_block();
	fall_timer.start();
	
	game_state = get_node("/root/TGameState");
	game_state.level_up.connect(_on_level_up);
	game_state.level_up.connect(hud._on_level_update);
	game_state.score_up.connect(hud._on_score_update);
	game_status = true;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if game_status:
		if Input.is_action_just_pressed("move_down"):
			fall_timer.start()
	
	if Input.is_action_just_pressed("restart"):
			table.reset();
			table.spawn_block();
			fall_timer.start();
			game_status = true;
			$HUD/GameOverLabel.hide();
	
	if Input.is_action_just_pressed("exit"):
		get_tree().quit();

func _on_game_over() -> void:
	fall_timer.stop();
	game_status = false;
	$HUD/GameOverLabel.show();
	game_state.reset();

func _on_level_up(level: int) -> void:
	fall_timer.wait_time *= game_state.FALL_MULTIPLIER;
	
