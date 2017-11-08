extends Area2D

var snake_speed = 0.2
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


func move_to(direction):
	state = STATE_INTWEEN
	target_direction = direction
	tween.interpolate_property(self, "transform/pos", start_position, start_position + direction, snake_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func destroy():
	queue_free()
	var explode = world.explode_class.instance()
	explode.set_pos(get_pos())
	world.add_child(explode)


func is_moving():
	return target_direction.x + target_direction.y != 0

func set_texture(texture):
	get_node("sprite").set_texture(texture)

func deactivate():
	active = false