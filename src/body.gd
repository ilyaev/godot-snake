extends Area2D

var target_direction = Vector2(0,0)
var target_position = Vector2(0,0)
var next_target_direction = Vector2(0,0)
var snake_speed = 0.2
var start_position = Vector2(0, 0)

const STATE_START = 1
const STATE_INTWEEN = 2
const STATE_END = 3

var state = STATE_START
var active = true


onready var tween = get_node("tween")
onready var world = get_node("/root/world")

signal move_finish
signal collide

func _ready():
	set_process(true)
	tween.connect("tween_complete", self, "tween_complete")

func relocate(position):
	set_pos(position)
	target_position = get_pos()
	start_position = get_pos()
	target_direction = Vector2(0,0)
	next_target_direction = Vector2(0,0)


func tween_complete(obj, key):
	set_pos(target_position)
	if !active:
		return
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

func set_target(direction):
	next_target_direction = direction

func destroy():
	var explode = world.explode_class.instance()
	explode.set_pos(get_pos())
	get_node("/root/world").add_child(explode)
	queue_free()


func set_texture(texture):
	get_node("sprite").set_texture(texture)

func deactivate():
	active = false