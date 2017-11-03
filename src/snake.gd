extends Node2D

onready var head = get_node("head")
onready var tail = get_node("tail")
onready var map = get_node("/root/world/walls")
onready var foods = get_node("/root/world/foods")
onready var world = get_node("/root/world")


var directions = []

var needGrow = false
var needShrink = false
var current_direction = Vector2(0,0)
var food = false
var path = []
var commands = []
var id

var food_scenario = [] # [Vector2(2,1), Vector2(2, 5), Vector2(1,7)]
var active = false

signal collide
signal tail_shrink

func _ready():
	directions = [Vector2(-1, 0), Vector2(1,0), Vector2(0, -1), Vector2(0,1)]
	head.add_to_group("head")
	relocate(head.get_pos())
	call_deferred("doGrow")
	head.connect("move_finish", self, "next_move")
	if is_in_group("foe"):
		head.set_texture(world.enemy_head_texture)
	active = true


func relocate(position):
	head.relocate(position)

func is_moving():
	if !active:
		return true
	if current_direction.x == 0 and current_direction.y == 0:
		return false
	if head.target_direction.x == 0 and head.target_direction.y == 0:
		return false
	else:
		return true

func next_move():
	if !active:
		return
	head.get_node("sprite").set_flip_h(head.target_direction.x < 0)
	head.set_rot(0)

	var last_body = tail.get_children().back()
	var prelast_body = head
	if tail.get_children().size() > 2:
		prelast_body = tail.get_children()[tail.get_children().size() - 2]

	var tdiff = prelast_body.get_pos() - last_body.get_pos()

	last_body.get_node("sprite").set_flip_h(tdiff.x < 0)
	last_body.set_rot(0)

	if tdiff.y < 0:
		last_body.set_rot(PI / 2)
	elif tdiff.y > 0:
		last_body.set_rot(-PI / 2)




	if head.target_direction.y < 0:
		head.set_rot(PI/2)
	elif head.target_direction.y > 0:
		head.set_rot(-PI/2)
	if needGrow:
		doGrow()
		needGrow = false
	if needShrink:
		doShrink()
		needShrink = false

	snake_next_command()

func snake_next_command():
	map.build_wall_map()
	for one_food in foods.get_children():
		if map.world_to_map(head.get_pos()) == map.world_to_map(one_food.get_pos()):
			doGrow()
			if get_size() == 2: # double grow after first body part. weird bug
				doGrow()
			if one_food and one_food.snake:
				spawn_food_by_snake(one_food.snake)
				# call_deferred("spawn_food_by_snake", one_food.snake)

	if is_in_group("foe") and commands.size() > 0:
		next_command()

	var next_cell = map.world_to_map(head.get_pos() + head.target_direction)
	var head_snakes = world.check_heads(self)

	if head_snakes.size() > 0:
		if is_in_group("foe"):
			destroy()
		else:
			emit_signal("collide")
			food.destroy()
		for one in head_snakes:
			if one.is_in_group("foe"):
				one.destroy()
			else:
				one.emit_signal("collide")
				one.food.destroy()
	elif next_cell.x < 0 or next_cell.y < 0 or next_cell.x > map.maxX - 1 or next_cell.y > map.maxY - 1 or map.wall_map[map.get_cell_id(next_cell.x, next_cell.y)]:
		snake_collide()

func spawn_food_by_snake(snake):
	if !snake or snake == null or !weakref(snake).get_ref() or !world.snakes.get_children().has(snake) or !snake.active or !snake.has_method("spawn_food"):
		return
	snake.spawn_food()
	if snake.is_in_group("foe"):
		snake.food.set_texture(world.enemy_food_texture)
	snake.find_route()
	if snake != self:
		snake.shrink()

func snake_collide():
	if !is_moving():
		return

	if is_in_group("foe"):
		find_route()
		if path.size() == 0:
			destroy()
			emit_signal("collide")
		else:
		 	next_command()
	else:
		destroy()
		emit_signal("collide")

func spawn_food():
	if food:
		food.destroy()
		food = false

	food = world.food_class.instance()
	food.add_to_group("food")
	foods.add_child(food)
	food.snake = self

	randomize()

	var food_x = round(rand_range(0, map.maxX - 1))
	var food_y = round(rand_range(0, map.maxY - 1))

	while map.wall_map[map.get_cell_id(food_x, food_y)] == true:
		food_x = round(rand_range(0, map.maxX - 1))
		food_y = round(rand_range(0, map.maxY - 1))

	if food_scenario.size() > 0:
		var _f = food_scenario[0]
		food_scenario.pop_front()
		food_x = _f.x
		food_y = _f.y

	food.set_pos(map.map_to_screen(Vector2(food_x, food_y)))


func set_target(direction):
	current_direction = direction
	head.set_target(direction)
	var prev = head
	for one in tail.get_children():
		one.set_target(prev.target_position - one.target_position)
		prev = one

func grow():
	needGrow = true

func shrink():
	needShrink = true

func get_size():
	return tail.get_child_count()

func doShrink():
	if tail.get_children().size() > 2:
		if is_in_group("foe"):
			tail.get_children()[tail.get_children().size() - 2].set_texture(world.enemy_snake_tail_texture)
		else:
			tail.get_children()[tail.get_children().size() - 2].set_texture(world.snake_tail_texture)
		var pos = tail.get_children().back().get_pos()
		tail.get_children().back().destroy()
		tail.get_children().pop_back()
		emit_signal("tail_shrink", pos)


func doGrow():
	var one = world.body_class.instance()
	var last = head

	if tail.get_child_count() > 0:
		last = tail.get_child(tail.get_child_count() - 1)

	for body in tail.get_children():
		if is_in_group("foe"):
			body.set_texture(world.enemy_snake_body_texture)
		else:
			body.set_texture(world.snake_body_texture)

	tail.add_child(one)
	if is_in_group("foe"):
		one.set_texture(world.enemy_snake_tail_texture)
	else:
		one.set_texture(world.snake_tail_texture)
	one.relocate(last.get_pos())

func _set_path(new_path):
	commands.clear()
	var cur_pos = map.world_to_map(head.get_pos())
	for node in new_path:
		commands.append(Vector2(node.x, node.y) - cur_pos)
		cur_pos = Vector2(node.x, node.y)
	path = new_path

func find_route():
	path.resize(0)
	var default_path = []
	for direction in directions:
		if path.size() == 0 and !map.is_wall_world(head.get_pos() + direction * map.snake_size):
			if default_path.size() == 0:
				default_path.append(map.world_to_map(head.get_pos() + direction * map.snake_size))
			_set_path(map.get_path(map.world_to_map(head.get_pos() + direction * map.snake_size), map.world_to_map(food.get_pos())))
	if path.size() == 0:
		if default_path.size() > 0:
			_set_path([Vector3(default_path[0].x, default_path[0].y, 0)])

func next_command():
	if commands.size() > 0:
		var command = commands[0]
		commands.pop_front()
		path.remove(0)
		set_target(command * map.snake_size)
		head.target_direction = head.next_target_direction

func build_path():
	find_route()
	next_command()

func destroy():
	food.destroy()
	deactivate()
	for body in tail.get_children():
		body.destroy()
	head.destroy()
	if is_in_group("foe"):
		queue_free()


func deactivate():
	active = false
	head.deactivate()
	for body in tail.get_children():
		body.deactivate()