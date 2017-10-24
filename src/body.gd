extends Area2D

var target_direction = Vector2(0,0)
var target_position = Vector2(0,0)
var next_target_direction = Vector2(0,0)
var snake_speed = 0.2
var start_position = Vector2(0, 0)
var tween_rot

const STATE_START = 1
const STATE_INTWEEN = 2
const STATE_END = 3

var state = STATE_START

onready var tween = get_node("tween")

signal move_finish
signal collide

func _ready():
	set_process(true)
	tween.connect("tween_complete", self, "tween_complete")
	tween_rot = Tween.new()
	add_child(tween_rot)
	tween_rot.connect("tween_complete", self, "tween_rot_complete")
	tween_rot_complete(self, "transform/rot")

func relocate(position):
	set_pos(position)
	target_position = get_pos()
	start_position = get_pos()
	target_direction = Vector2(0,0)
	next_target_direction = Vector2(0,0)

func tween_rot_complete(obj, key):
	tween_rot.interpolate_property(self, "transform/rot", 0, 180, snake_speed * 5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween_rot.start()

func tween_complete(obj, key):
	set_pos(target_position)
	target_direction = next_target_direction
	target_position = get_pos() + target_direction
	start_position = get_pos()
	emit_signal("move_finish")
	target_direction = next_target_direction
	target_position = get_pos() + target_direction
	start_position = get_pos()
	state = STATE_END

func _process(delta):

	if state != STATE_INTWEEN:
		state = STATE_INTWEEN
		tween.interpolate_property(self, "transform/pos", start_position, target_position, snake_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()

		# if !tween_rot.is_active():
		# 	tween_rot.interpolate_property(self, "transform/rot", 0, 180, snake_speed * 5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		# 	tween_rot.start()


	if is_in_group("head") and get_overlapping_areas().size() > 0 and (target_direction.x > 0 or target_direction.y > 0):
		emit_signal("collide")

func set_target(direction):
	next_target_direction = direction
