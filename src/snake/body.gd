extends Area2D

var speed = 0.2
var next_speed = 0.2
var start_position = Vector2(0, 0)
var start_position_map = Vector2(0, 0)
var target_direction = Vector2(0, 0)
var current_target_direction = Vector2(0, 0)
var target_position = Vector2(0, 0)
var target_position_map = Vector2(0, 0)
var target_direction_map = Vector2(0, 0)

const STATE_STOP = 0
const STATE_START = 1
const STATE_INTWEEN = 2
const STATE_END = 3

var state = STATE_STOP
var active = true

var map_pos = Vector2(0, 0)

var shift = Vector2(0,0)
var all_time = 0
var moves = 0

var is_head = false


onready var tween = get_node("tween")
onready var world = get_node("/root/world")
onready var rotation = get_node("rotation")

signal move_finish
signal collide

func _ready():
	is_head = is_in_group("head")
	tween.connect("tween_complete", self, "tween_complete")
	all_time = 0
	set_fixed_process(true)

func _fixed_process(delta):
	all_time = all_time + delta
	if all_time >= (speed + delta) and state == STATE_INTWEEN:
		state = STATE_END
		# set_pos(world.map.map_to_screen(target_position_map))
		emit_signal("move_finish")
	else:
		set_pos(get_pos() + current_target_direction * ( delta / speed ))

func relocate(position):
	set_pos(position)
	start_position = get_pos()
	target_position = get_pos()

func relocate_on_map(position):
	start_position_map = position
	target_position_map = position


func tween_complete(obj, key):
	state = STATE_END
	set_pos(target_position)
	start_position = get_pos()
	emit_signal("move_finish")

func move_to_map(direction, next_direction):

	var diff = (target_position_map + direction) - target_position_map

	start_position_map = target_position_map
	target_position_map = start_position_map + direction
	target_direction_map = direction

	var start_rotation = round(get_rot() / 90)
	var corner_transition = Tween.TRANS_SINE


	if direction.x == 0 and next_direction.x != 0:
		rotation.interpolate_property(self, "transform/rot", start_rotation, start_rotation + 90 * sign(next_direction.x) * sign(direction.y), speed, corner_transition, Tween.EASE_IN_OUT)
		rotation.start()
	if direction.y == 0 and next_direction.y != 0:
		rotation.interpolate_property(self, "transform/rot", start_rotation, start_rotation - 90 * sign(next_direction.y) * sign(direction.x), speed, corner_transition, Tween.EASE_IN_OUT)
		rotation.start()

func move_to(direction):
	state = STATE_INTWEEN
	moves = moves + 1

	start_position = target_position # get_pos()
	target_position = start_position + direction
	target_direction = target_position - get_pos()
	current_target_direction = target_direction

	all_time = 0


func destroy():
	queue_free()

func explode(pos):
	var explode = world.explode_class.instance()
	explode.set_pos(pos)
	world.add_child(explode)
	queue_free()


func is_moving():
	return target_direction.x + target_direction.y != 0

func set_texture(texture):
	get_node("sprite").set_texture(texture)

func get_texture():
	return get_node("sprite").get_texture()

func deactivate():
	active = false

