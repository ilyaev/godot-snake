extends Area2D

var target_direction = Vector2(0,0)
var target_position = Vector2(0,0)
var next_target_direction = Vector2(0,0)
var speed = 10
var iteration = 0

signal move_finish
signal collide

func _ready():
	set_process(true)

func relocate(position):
	set_pos(position)
	target_position = get_pos()
	target_direction = Vector2(0,0)
	next_target_direction = Vector2(0,0)
	iteration = 0

func _process(delta):
	if iteration == 0:
		iteration = speed
		target_direction = next_target_direction
		target_position = get_pos() + target_direction
		emit_signal("move_finish")
	else:
		set_pos(get_pos() + target_direction / speed)
		iteration -= 1

	if is_in_group("head") and get_overlapping_areas().size() > 0 and (target_direction.x > 0 or target_direction.y > 0):
		emit_signal("collide")

func set_target(direction):
	next_target_direction = direction
