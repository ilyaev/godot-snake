extends Node2D

onready var head = get_node("head")
onready var tail = get_node("tail")
var body = preload("res://src/body.tscn")
var needGrow = false
var current_direction = Vector2(0,0)
var id = -1
var food = false

func _ready():
	head.add_to_group("head")
	relocate(head.get_pos())
	call_deferred("doGrow")
	head.connect("move_finish", self, "next_move")
	randomize()
	id = round(rand_range(0, 100000))

func relocate(position):
	head.relocate(position)

func is_moving():
	if current_direction.x == 0 and current_direction.y == 0:
		return false
	else:
		return true

func next_move():
	head.get_node("sprite").set_flip_h(head.target_direction.x < 0)
	head.set_rot(0)
	if head.target_direction.y < 0:
		head.set_rot(PI/2)
	elif head.target_direction.y > 0:
		head.set_rot(-PI/2)
	if needGrow:
		doGrow()
		needGrow = false

func set_target(direction):
	current_direction = direction
	head.set_target(direction)
	var prev = head
	for one in tail.get_children():
			one.set_target(prev.target_position - one.target_position)
			prev = one

func grow():
	needGrow = true

func get_size():
	return tail.get_child_count()

func doGrow():
	var one = body.instance()
	var last = head

	if tail.get_child_count() > 0:
		last = tail.get_child(tail.get_child_count() - 1)

	tail.add_child(one)
	one.relocate(last.get_pos())
