extends Node2D

var table: Table;
var fall_timer: Timer;

var game_status: bool = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	table = $Table as Table;
	fall_timer = $UpdateTimer;
	
	table.game_over.connect(_on_game_over);
	table.spawn_block();
	fall_timer.start();
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

