extends Node2D

onready var head = get_node("head")
onready var tail = get_node("tail")
onready var map = get_node("/root/world/walls")
onready var foods = get_node("/root/world/foods")
onready var world = get_node("/root/world")
onready var animation = get_node("animation")

const SNAKE_STATE_NORMAL = 0
const SNAKE_STATE_INVINCIBLE = 1
const SNAKE_STATE_FLASH = 2
const SNAKE_STATE_SLOW = 3
const SNAKE_STATE_INACTIVE = 4


const SNAKE_CONTROLLER_INPUT = 0
const SNAKE_CONTROLLER_AI_ASTAR = 1
const SNAKE_CONTROLLER_AI_DQN = 2

var state
var state_id = SNAKE_STATE_NORMAL
var states_classes = [
	preload("state/normal.gd").new(),
	preload("state/invincible.gd").new(),
	preload("state/flash.gd").new(),
	preload("state/slow.gd").new(),
	preload("state/inactive.gd").new()
]

var to_be_destroyed = false

var controller
var controller_id
var controller_classes = [
	preload("controller/input.gd").new(),
	preload("controller/ai_astar.gd").new(),
	preload("controller/ai_dqn.gd").new()
]


var score = 0
var speed = 1
var next_speed = 1
var base_speed = 0.2
var start_speed = 1
var speed_rate = 0.007
var old_speed = 0
var lifes = 4
var next_action = []

var current_direction = Vector2(0,0)
var current_command = ''
var immediate_direction = Vector2(0,0)
var food = false
var path = []
var commands = []
var id
var turn = 1
var search_food = false
var need_shrink = false
var all_time = 0
var thread

var active = false
var calculating = false

signal collide
signal tail_shrink
signal after_move
signal next_level

func _ready():
	for one in states_classes:
		add_child(one)
	for one in controller_classes:
		add_child(one)

	head.add_to_group("head")
	head.speed = speed
	relocate(head.get_pos())
	head.connect("move_finish", self, "next_move")
	if is_in_group("foe"):
		head.set_texture(world.enemy_head_texture)
	animation.play("show")
	set_speed(start_speed)
	if !is_in_group("foe"):
		set_state(SNAKE_STATE_INVINCIBLE, 3)
	else:
		set_state(SNAKE_STATE_NORMAL)
	all_time = 0
	set_fixed_process(true)

func _fixed_process(delta):
	if !calculating:
		if next_action.size() > 0:
			var action = next_action[0]
			next_action.resize(0)
			var pos = map.world_to_map(head.get_pos())
			if map.is_wall(Vector2(pos.x + action.dx, pos.y + action.dy)) and state_id != SNAKE_STATE_INVINCIBLE:
				action = controller.random_action()
			var command = Vector2(action.dx, action.dy)
			set_target(command * map.snake_size)
			further_command()

		state.fixed_process(delta)

func set_controller(new_controller):
	controller_id = new_controller
	controller = controller_classes[new_controller]
	controller.snake = self
	controller.do_on_enter()

func set_state(new_state, timeout = 0):
	state_id = new_state

	if state and state.has_method("on_exit_state"):
		state.on_exit_state()

	state = states_classes[new_state]
	state.snake = self
	state.do_on_enter(timeout)

func relocate(position):
	head.relocate(position)
	head.relocate_on_map(map.world_to_map(position))

func is_moving():
	if calculating:
		return false
	if !active:
		return true
	if current_direction.x == 0 and current_direction.y == 0:
		return false
	if head.target_direction.x == 0 and head.target_direction.y == 0:
		return false
	else:
		return true

func next_move():
	state.next_move()
	all_time = 0

func snake_next_command():
	turn += 1

	if search_food:
		search_food = false
		controller.find_route()

	controller.next_command()
	# controller.call_deferred('next_command')

func further_command():
	var head_pos = map.world_to_map(head.get_pos())

	for one_food in foods.get_children():
		if one_food and one_food.has_method("queue_free") and one_food.active == true and head_pos == one_food.get_map_pos() && one_food.effect_type != 'Static':
			state.eat_food(one_food)

	var next_cell = map.world_to_map(head.get_pos() + head.target_direction)
	if next_cell.x < 0 or next_cell.y < 0 or next_cell.x > map.maxX - 1 or next_cell.y > map.maxY - 1 or map.wall_map[map.get_cell_id(next_cell.x, next_cell.y)]:
		snake_collide()
	elif map.is_portal(next_cell) and !is_in_group("foe"):
		state.next_level()

	move_to_target()

	if is_moving() and active == true:
		map.add_wall_map(head.target_position_map)
		var tail_body = head

		if tail.get_children().size() > 0:
			tail_body = tail.get_children().back()

		map.remove_wall_map(tail_body.start_position_map)

	if need_shrink:
		need_shrink = false
		doShrink()



func spawn_food_by_snake(food_snake):
	if !food_snake or food_snake == null or !weakref(food_snake).get_ref() or !world.snakes.get_children().has(food_snake) or !food_snake.active or !food_snake.has_method("spawn_food"):
		return

	food_snake.spawn_food()

	if food_snake == self:
		self.controller.new_food_arrived()
	else:
		food_snake.controller.new_food_arrived_deferred()
		# food_snake.need_shrink = true


func snake_collide():
	state.snake_collide()

func spawn_food():
	if food:
		food.destroy()
		food = false
	world.spawn_food(self)


func set_target(direction):
	current_direction = direction
	head.target_direction = direction
	if head.state == head.STATE_STOP:
		move_to_target()


func move_to_target():
	if !active:
		return

	var snake_speed = base_speed / speed
	var dir64 = current_direction / 64

	head.move_to_map(dir64, Vector2(0,0), snake_speed)
	head.move_to(current_direction)

	immediate_direction = current_direction
	var prev = head
	var prev_prev = head.start_position_map + dir64
	for one in tail.get_children():
		one.move_to_map(prev.start_position_map - one.target_position_map, prev_prev - prev.start_position_map, snake_speed)
		one.move_to(map.map_to_screen(prev.start_position_map) - one.get_pos())
		prev_prev = prev.start_position_map
		prev = one

func get_size():
	return tail.get_child_count()

func doShrink():
	state.doShrink()


func doGrow():
	var one = world.body_class.instance()
	var last = head
	var prev_size = get_size()

	if tail.get_child_count() > 0:
		last = tail.get_children().back()
		if is_in_group("foe"):
			last.set_texture(world.enemy_snake_body_texture)
		else:
			last.set_texture(world.snake_body_texture)

	tail.add_child(one)

	if is_in_group("foe"):
		one.set_texture(world.enemy_snake_tail_texture)
	else:
		one.set_texture(world.snake_tail_texture)

	if prev_size == 0:
		one.relocate(map.map_to_screen(last.start_position_map))
		one.relocate_on_map(last.start_position_map)
	else:
		one.relocate(map.map_to_screen(last.target_position_map))
		one.relocate_on_map(last.target_position_map)

func clear_path():
	path.resize(0)

func next_command():
	# controller.call_deferred('next_command')
	controller.next_command()

func destroy():
	to_be_destroyed = true
	# state.call_deferred("destroy")
	state.destroy()
	if is_in_group("foe"):
		world.spawn_food(false)


func deactivate():
	state.deactivate()


func _on_animation_finished():
	state.on_animation_finished()

func ready_to_start():
	# call_deferred("doGrow")
	doGrow()
	active = true
	if is_in_group("foe"):
		next_command()


func set_speed(new_speed):
	next_speed = new_speed


func _notification(what):
	pass
	# if what == NOTIFICATION_PREDELETE:
	# 	controller_classes.resize(0)
	# 	states_classes.resize(0)
