extends Node2D

onready var head = get_node("head")
onready var tail = get_node("tail")
onready var map = get_node("/root/world/walls")
onready var foods = get_node("/root/world/foods")
onready var world = get_node("/root/world")
onready var animation = get_node("animation")


var directions = []
var score = 0
var speed = 0.2

var current_direction = Vector2(0,0)
var food = false
var path = []
var commands = []
var id
var turn = 1
var search_food = false
var need_shrink = false

var food_scenario = []#[Vector2(1,0), Vector2(2, 5), Vector2(1,7)]
var active = false

signal collide
signal tail_shrink
signal after_move

func _ready():
	directions = [Vector2(-1, 0), Vector2(1,0), Vector2(0, -1), Vector2(0,1)]
	head.add_to_group("head")
	head.speed = speed
	relocate(head.get_pos())
	head.connect("move_finish", self, "next_move")
	if is_in_group("foe"):
		head.set_texture(world.enemy_head_texture)
	animation.play("show")



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

	var last_body = head
	var prelast_body = head

	if tail.get_children().size() > 0:
		last_body = tail.get_children().back()

	if tail.get_children().size() > 1:
		prelast_body = tail.get_children()[tail.get_children().size() - 2]

	var tdiff = prelast_body.get_pos() - last_body.get_pos()

	last_body.get_node("sprite").set_flip_h(tdiff.x < 0)
	last_body.set_rot(0)

	if tdiff.y < 0:
		last_body.set_rot(PI / 2)
	elif tdiff.y > 0:
		last_body.set_rot(-PI / 2)



	snake_next_command()

	if head.target_direction.y < 0:
		head.set_rot(PI/2)
	elif head.target_direction.y > 0:
		head.set_rot(-PI/2)

	emit_signal("after_move")


func snake_next_command():

	turn += 1

	if search_food:
		search_food = false
		find_route()

	if is_in_group("foe"):
		next_command()
	else:
		set_target(world.direction)

	for one_food in foods.get_children():
		if map.world_to_map(head.get_pos()) == map.world_to_map(one_food.get_pos()):
			score += one_food.experience
			doGrow()
			if one_food and one_food.snake:
				spawn_food_by_snake(one_food.snake)

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

	move_to_target()

	if is_moving() and active == true:
		map.add_wall(head.get_pos() + head.target_direction)
		var tail_body = head
		if tail.get_children().size() > 0:
			tail_body = tail.get_children().back()
		map.remove_wall(tail_body.start_position)


	if need_shrink:
		need_shrink = false
		doShrink()





func spawn_food_by_snake(snake):
	if !snake or snake == null or !weakref(snake).get_ref() or !world.snakes.get_children().has(snake) or !snake.active or !snake.has_method("spawn_food"):
		return
	snake.spawn_food()
	if snake.is_in_group("foe"):
		if snake == self:
			snake.find_route()
			snake.next_command()
		else:
			snake.search_food = true

	if snake != self:
		snake.need_shrink = true

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
	world.spawn_food(self)


func set_target(direction):
	current_direction = direction
	head.target_direction = direction
	if head.state == head.STATE_STOP:
		move_to_target()


func move_to_target():
	if !active:
		return
	head.move_to(current_direction, Vector2(0,0))
	var prev = head
	var prev_prev = head.get_pos() + current_direction
	for one in tail.get_children():
		one.move_to(prev.get_pos() - one.get_pos(), prev_prev - prev.get_pos())
		prev_prev = prev.get_pos()
		prev = one

func get_size():
	return tail.get_child_count()

func doShrink():
	if tail.get_children().size() > 1:
		if is_in_group("foe"):
			tail.get_children()[tail.get_children().size() - 2].set_texture(world.enemy_snake_tail_texture)
		else:
			tail.get_children()[tail.get_children().size() - 2].set_texture(world.snake_tail_texture)

		var back = tail.get_children().back()
		var pos = back.get_pos()
		map.remove_wall(pos + back.target_direction)
		back.destroy()
		world.add_explode(back.get_pos(), 1)
		emit_signal("tail_shrink", pos)


func doGrow():
	var one = world.body_class.instance()
	one.speed = speed
	var last = head

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
		if path.size() > 0:
			path.remove(0)
		if !map.is_wall_world(head.get_pos() + command * map.snake_size):
			set_target(command * map.snake_size)
		else:
			find_route()
			next_command()

func build_path():
	find_route()
	next_command()

func destroy():
	food.destroy()
	deactivate()

	world.add_explode(head.get_pos(), 1)
	head.destroy()
	for body in tail.get_children():
		world.add_explode(body.get_pos(), rand_range(0, 100))
		body.destroy()

	if is_in_group("foe"):
		queue_free()


func deactivate():
	active = false
	head.deactivate()
	map.remove_wall(head.get_pos())
	for body in tail.get_children():
		map.remove_wall(body.get_pos())
		body.deactivate()


func _on_animation_finished():
	if animation.get_current_animation() == 'show':
		ready_to_start()

func ready_to_start():
	active = true
	call_deferred("doGrow")
	if is_in_group("foe"):
		next_command()
