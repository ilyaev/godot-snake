extends Node2D

const snake_size = 8 * 8
const snake_scale = 1
var snake
var direction = Vector2(0,0)
var food_class = preload("res://src/food.tscn")
var snake_class = preload("res://src/snake.tscn")

var maxX = 0
var maxY = 0

const TILE_WALL = 1
const TILE_GRASS = 0
const TILE_WALL_LEFT = 3
const TILE_WALL_RIGHT = 2
const TILE_WALL_UP = 5
const TILE_WALL_DOWN = 4

onready var map = get_node("map")
onready var decor = get_node("walls")
onready var layers = [get_node("bg1"), get_node("bg2"), get_node("bg3"), get_node("bg4")]
onready var snakes = get_node("snakes")
onready var foods = get_node("foods")

func _ready():
	adjust_map()
	spawn_player_snake()
	set_process(true)

func spawn_player_snake():
	snake = snake_class.instance()
	snakes.add_child(snake)
	snake.relocate(map2cell(Vector2(1, 1)))
	snake.head.connect("move_finish", self, "snake_next_command", [snake])
	spawn_food(snake)

func spawn_enemy_snake():
	var foe = snake_class.instance()
	snakes.add_child(foe)
	foe.relocate(map2cell(Vector2(1,1)))
	foe.set_target(direction)
	foe.head.connect("move_finish", self, "snake_next_command", [foe])
	foe.add_to_group("foe")
	spawn_food(foe)

func map2cell(vector):
	return Vector2(vector.x * snake_size * snake_scale + (snake_size / 2), vector.y * snake_size * snake_scale + (snake_size / 2) )


func spawn_food(snake):
	if !snake.food:
		snake.food = food_class.instance()
		snake.food.add_to_group("food")
		foods.add_child(snake.food)

	randomize()

	var food_x = round(rand_range(0, maxX - 1))
	var food_y = round(rand_range(0, maxY - 1))

	while decor.get_cell(food_x, food_y) != -1:
		food_x = round(rand_range(0, maxX - 1))
		food_y = round(rand_range(0, maxY - 1))

	snake.food.set_pos(map2cell(Vector2(food_x, food_y)))

func snake_next_command(snake):
	var food = snake.food
	var next_cell = map.world_to_map(snake.head.get_pos() + snake.head.target_direction)

	if next_cell.x < 0 or next_cell.y < 0 or next_cell.x > maxX - 1 or next_cell.y > maxY - 1 or decor.get_cell(next_cell.x, next_cell.y) == TILE_WALL:
		snake_collide(snake)

	if food and map.world_to_map(snake.head.get_pos()) == map.world_to_map(food.get_pos()):
		snake.doGrow()
		if snake.get_size() == 2: # double grow after first body part. weird bug
			snake.doGrow()
		spawn_food(snake)

func snake_collide(snake):
	snake.food.queue_free()
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

func adjust_map():
	maxX = map.get_used_rect().end.x
	maxY = map.get_used_rect().end.y
	for x in range(map.get_used_rect().end.x):
		for y in range(map.get_used_rect().end.y):
			map.set_cell(x, y, TILE_GRASS)
			if decor.get_cell(x,y) == TILE_WALL:
				continue
			var d_map = {
				"self": decor.get_cell(x, y),
				"left": decor.get_cell(x-1, y),
				"right": decor.get_cell(x+1, y),
				"up": decor.get_cell(x, y-1),
				"down": decor.get_cell(x, y+1)
			}

			var index = 0

			if d_map.left == 1 or x == 0:
				layers[index].set_cell(x,y,TILE_WALL_LEFT)
				index += 1
			if d_map.right == 1 or x == maxX - 1:
				layers[index].set_cell(x,y,TILE_WALL_RIGHT)
				index += 1
			if d_map.up == 1 or y == 0:
				layers[index].set_cell(x,y,TILE_WALL_UP)
				index += 1
			if d_map.down == 1 or y == maxY - 1:
				layers[index].set_cell(x,y,TILE_WALL_DOWN)
				index += 1

func _on_snake_spawn_timer_timeout():
	spawn_enemy_snake()
