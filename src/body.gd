extends Area2D

var speed = 0.2
var start_position = Vector2(0, 0)
var target_direction = Vector2(0, 0)

const STATE_STOP = 0
const STATE_START = 1
const STATE_INTWEEN = 2
const STATE_END = 3

var state = STATE_STOP
var active = true


onready var tween = get_node("tween")
onready var world = get_node("/root/world")
onready var rotation = get_node("rotation")

signal move_finish
signal collide

func _ready():
	tween.connect("tween_complete", self, "tween_complete")

func relocate(position):
	set_pos(position)
	start_position = get_pos()


func tween_complete(obj, key):
	state = STATE_END
	start_position = get_pos()
	emit_signal("move_finish")


func move_to(direction, next_direction):
	state = STATE_INTWEEN

	var corner_transition = Tween.TRANS_SINE
	var start_rotation = round(get_rot() / 90)

	target_direction = direction
	tween.interpolate_property(self, "transform/pos", start_position, start_position + direction, speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

	if direction.x == 0 and next_direction.x != 0:
		rotation.interpolate_property(self, "transform/rot", start_rotation, start_rotation + 90 * sign(next_direction.x) * sign(direction.y), speed, corner_transition, Tween.EASE_IN_OUT)
		rotation.start()
	if direction.y == 0 and next_direction.y != 0:
		rotation.interpolate_property(self, "transform/rot", start_rotation, start_rotation - 90 * sign(next_direction.y) * sign(direction.x), speed, corner_transition, Tween.EASE_IN_OUT)
		rotation.start()

func destroy():
	queue_free()

func explode(pos):
	print("EXP", pos)
	var explode = world.explode_class.instance()
	explode.set_pos(pos)
	world.add_child(explode)
	queue_free()


func is_moving():
	return target_direction.x + target_direction.y != 0

func set_texture(texture):
	get_node("sprite").set_texture(texture)

func deactivate():
	active = false

