extends Node2D

const snake_size = 8 * 8
const snake_scale = 1
var snake
var direction = Vector2(0,0)
var food_class = preload("res://src/food.tscn")
var snake_class = preload("res://src/snake.tscn")
var path = []

onready var map = get_node("walls")
onready var snakes = get_node("snakes")
onready var foods = get_node("foods")

func _ready():
	spawn_player_snake()
	set_process(true)

func _draw():
	if snake.path.size() > 0:
		for cell in snake.path:
			draw_circle(map.map_to_screen(cell), 20, Color(1,0,0,0.5))

	for one_snake in snakes.get_children():
		if one_snake.is_in_group("foe") and one_snake.path.size() > 0:
			for cell in one_snake.path:
				draw_circle(map.map_to_screen(cell), 15, Color(0,0,1,0.5))


func spawn_player_snake():
	snake = snake_class.instance()
	snakes.add_child(snake)
	snake.relocate(map.map_to_screen(Vector2(1, 1)))
	snake.head.connect("move_finish", self, "snake_next_command", [snake])
	spawn_food(snake)

func spawn_enemy_snake():
	var foe = snake_class.instance()
	snakes.add_child(foe)
	foe.relocate(map.map_to_screen(Vector2(1,1)))
	foe.set_target(direction)
	foe.head.connect("move_finish", self, "snake_next_command", [foe])
	foe.add_to_group("foe")
	spawn_food(foe)
	build_snake_path(foe)
	map.build_wall_map()

func build_snake_path(foe):
	foe.path = map.get_path(map.world_to_map(foe.head.get_pos() + foe.current_direction), map.world_to_map(foe.food.get_pos()))
	if foe.commands.size() > 0:
		var command = foe.commands[0]
		foe.commands.pop_front()
		foe.set_target(command * snake_size)

func spawn_food(snake):
	if snake.food:
		snake.food.destroy()
		snake.food = false

	if !snake.food:
		snake.food = food_class.instance()
		snake.food.add_to_group("food")
		foods.add_child(snake.food)
		snake.food.snake = snake

	randomize()

	var food_x = round(rand_range(0, map.maxX - 1))
	var food_y = round(rand_range(0, map.maxY - 1))

	while map.wall_map[map.get_cell_id(food_x, food_y)] == true:
		food_x = round(rand_range(0, map.maxX - 1))
		food_y = round(rand_range(0, map.maxY - 1))

	snake.food.set_pos(map.map_to_screen(Vector2(food_x, food_y)))

func snake_next_command(snake):
	var food = snake.food
	var next_cell = map.world_to_map(snake.head.get_pos() + snake.head.target_direction)

	if next_cell.x < 0 or next_cell.y < 0 or next_cell.x > map.maxX - 1 or next_cell.y > map.maxY - 1 or map.wall_map[map.get_cell_id(next_cell.x, next_cell.y)]:
		snake_collide(snake)

	if food and map.world_to_map(snake.head.get_pos()) == map.world_to_map(food.get_pos()):
		snake.doGrow()
		if snake.get_size() == 2: # double grow after first body part. weird bug
			snake.doGrow()
		spawn_food(snake)
		build_snake_path(snake)

	map.build_wall_map()

	if snake.is_moving():
		if snake.path.size() == 0:
			snake.path = map.get_path(map.world_to_map(snake.head.get_pos() + snake.current_direction), map.world_to_map(snake.food.get_pos()))
		if snake.is_in_group("foe"):
			if snake.commands.size() > 0:
				var command = snake.commands[0]
				snake.commands.pop_front()
				# snake.path.pop_front()
				snake.set_target(command * snake_size)
	else:
		snake.path = []

func snake_collide(snake):
	if !snake.is_moving():
		return

	snake.food.destroy()
	snake.queue_free()
	if !snake.is_in_group("foe"):
		spawn_player_snake()
		direction.x = 0
		direction.y = 0

func _process(delta):
	if Input.is_action_pressed("ui_right"):
		direction.x = snake_size * snake_scale
		direction.y = 0
	elif Input.is_action_pressed("ui_left"):
		direction.x = -snake_size * snake_scale
		direction.y = 0
	elif Input.is_action_pressed("ui_up"):
		direction.x = 0
		direction.y = -snake_size * snake_scale
	elif Input.is_action_pressed("ui_down"):
		direction.x = 0
		direction.y = snake_size * snake_scale
	elif Input.is_action_pressed("ui_accept"):
		get_tree().set_pause(true)


	if snake:
		snake.set_target(direction)

	for foe in snakes.get_children():
		if foe.is_in_group("foe"):
			foe.set_target(foe.current_direction)

	update()

func _on_snake_spawn_timer_timeout():
	if direction.x != 0 or direction.y != 0:
		spawn_enemy_snake()
