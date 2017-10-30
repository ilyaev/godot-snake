extends Node2D

var snake
var direction = Vector2(0,0)
var snake_class = preload("res://src/snake.tscn")
var snake_tail_texture = preload("res://art/medium/snake_tail.png")
var snake_body_texture = preload("res://art/medium/sprite_01.png")
var last_id = 0

export var show_debug = true

onready var map = get_node("walls")
onready var snakes = get_node("snakes")
onready var foods = get_node("foods")

func _ready():
	spawn_player_snake()
	spawn_enemy_snake()
	set_process(true)


func spawn_player_snake():
	snake = snake_class.instance()
	snake.id = next_id()
	snake.connect("collide", self, "snake_collide", [snake])
	snakes.add_child(snake)
	snake.relocate(map.map_to_screen(Vector2(10, 1)))
	snake.spawn_food()

func spawn_enemy_snake():
	var foe = snake_class.instance()
	foe.id = next_id()
	snakes.add_child(foe)
	foe.relocate(map.map_to_screen(Vector2(3,1)))
	foe.set_target(direction)
	foe.add_to_group("foe")
	foe.spawn_food()
	map.build_wall_map()
	foe.find_route()

func next_id():
	last_id += 1
	return last_id

func check_heads(snake):
	var cell = map.world_to_map(snake.head.get_pos())
	var result = []
	for one in snakes.get_children():
		if one != snake and map.world_to_map(one.head.get_pos()) == cell:
			result.append(one)
	return result

func snake_collide(snake):
	if !snake.is_moving():
		return
	snake.queue_free()
	snake = false
	spawn_player_snake()
	direction.x = 0
	direction.y = 0

func _process(delta):
	if Input.is_action_pressed("ui_right"):
		direction.x = map.snake_size
		direction.y = 0
	elif Input.is_action_pressed("ui_left"):
		direction.x = -map.snake_size
		direction.y = 0
	elif Input.is_action_pressed("ui_up"):
		direction.x = 0
		direction.y = -map.snake_size
	elif Input.is_action_pressed("ui_down"):
		direction.x = 0
		direction.y = map.snake_size
	elif Input.is_action_pressed("ui_accept"):
		get_tree().set_pause(true)
	elif Input.is_action_pressed("ui_focus_next"):
		show_debug = !show_debug


	if snake:
		snake.set_target(direction)

	for foe in snakes.get_children():
		if foe.active and foe.is_in_group("foe"):
			foe.set_target(foe.current_direction)

	get_node("camera").align_to(snake.head.get_pos())

func _on_snake_spawn_timer_timeout():
	get_node("snake_spawn_timer").set_wait_time(2)
	spawn_enemy_snake()
