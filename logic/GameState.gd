class_name GameState extends Node;

signal level_up(level);
signal score_up(score);

const LINES_TO_LEVEL_UP: int = 1;
const FALL_MULTIPLIER: float = 0.9;
const SCORE_FOR_LINES: Array[int] = [0, 40, 100, 300, 1200];

var temp_cleared_lines: int = 0;
var level: int = 0;
var score: int = 0;

func score_update(cleared_lines: int) -> void:
	if (cleared_lines > 0):
		score += SCORE_FOR_LINES[cleared_lines] * (level + 1);
		temp_cleared_lines += cleared_lines;
		score_up.emit(score);
		if temp_cleared_lines >= LINES_TO_LEVEL_UP:
			temp_cleared_lines -= LINES_TO_LEVEL_UP;
			level += 1;
			level_up.emit(level);

func reset() -> void:
	level = 0;
	score = 0;
	temp_cleared_lines = 0;
