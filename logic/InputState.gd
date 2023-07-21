class_name InputState extends Object

var hmove: int;
var vmove: int;
var rotation: int;

var just_pressed: bool = false;
var initial_delay: float = 0.2;
var delay: float = 0.05;
var time_passed: float = 0.0;

func check_input(delta: float) -> void:
	reset();
	if Input.is_action_just_pressed("move_left"):
		hmove -= 1;
	if Input.is_action_just_pressed("move_right"):
		hmove += 1;
	if Input.is_action_just_pressed("move_down"):
		vmove = 1;
	if Input.is_action_just_pressed("rotate_ccw"):
		rotation += 3;
	if Input.is_action_just_pressed("rotate_cw"):
		rotation += 1;
	
	if hmove != 0 or vmove != 0 or rotation != 0:
		just_pressed = true;
		time_passed = 0.0;
		return;
	
	if (just_pressed && time_passed > initial_delay) \
	|| (!just_pressed && time_passed > delay):
		if Input.is_action_pressed("move_left"):
			hmove -= 1;
		if Input.is_action_pressed("move_right"):
			hmove += 1;
		if Input.is_action_pressed("move_down"):
			vmove = 1;
		if Input.is_action_pressed("rotate_ccw"):
			rotation += 3;
		if Input.is_action_pressed("rotate_cw"):
			rotation += 1;
		
		just_pressed = false;
		time_passed = 0.0;
		
	time_passed += delta;

func reset() -> void:
	hmove = 0;
	vmove = 0;
	rotation = 0;
