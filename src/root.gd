extends Node2D

var snake
var direction = Vector2(0,0)
var snake_class = preload("res://src/snake.tscn")
var snake_tail_texture = preload("res://art/medium/snake_tail.png")
var enemy_food_texture = preload("res://art/medium/sprite_03_1.png")
var enemy_snake_tail_texture = preload("res://art/medium/snake_tail_1.png")
var snake_body_texture = preload("res://art/medium/sprite_01.png")
var enemy_snake_body_texture = preload("res://art/medium/sprite_01_1.png")
var enemy_head_texture = preload("res://art/medium/sprite_02_1.png")
var explode_class = preload("res://src/explode.tscn")
var body_class = preload("res://src/body.tscn")
var food_class = preload("res://src/food.tscn")
var last_id = 0
var need_spawn = false

export var show_debug = true

onready var map = get_node("walls")
onready var snakes = get_node("snakes")
onready var foods = get_node("foods")

func _ready():
	spawn_player_snake()
	spawn_enemy_snake()
	set_process(true)
	set_process_input(true)
	self.show_debug = false

func _input(event):
	if event.is_action_pressed("ui_right"):
		direction.x = map.snake_size
		direction.y = 0
	elif event.is_action_pressed("ui_left"):
		direction.x = -map.snake_size
		direction.y = 0
	elif event.is_action_pressed("ui_up"):
		direction.x = 0
		direction.y = -map.snake_size
	elif event.is_action_pressed("ui_down"):
		direction.x = 0
		direction.y = map.snake_size
	elif event.is_action_pressed("ui_accept"):
		get_tree().set_pause(true)
	elif event.is_action_pressed("ui_focus_next"):
		self.show_debug = !self.show_debug

	snake.set_target(direction)



func spawn_player_snake():
	snake = snake_class.instance()
	snake.id = next_id()
	snake.connect("collide", self, "snake_collide", [snake])
	snake.connect("after_move", self, "game_tick")
	snakes.add_child(snake)
	snake.relocate(map.map_to_screen(Vector2(0, 0)))
	snake.spawn_food()
	map.add_wall(snake.head.get_pos())

func spawn_enemy_snake():
	var foe = snake_class.instance()
	foe.add_to_group("foe")
	foe.id = next_id()
	snakes.add_child(foe)
	foe.relocate(map.map_to_screen(Vector2(3,1)))
	foe.set_target(direction)
	foe.spawn_food()
	foe.food.set_texture(enemy_food_texture)
	map.add_wall(foe.head.get_pos())
	foe.find_route()

func game_tick():
	if need_spawn:
		need_spawn = false
		spawn_enemy_snake()

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
	get_node("camera").align_to(snake.head.get_pos())

func _on_snake_spawn_timer_timeout():
	get_node("snake_spawn_timer").set_wait_time(2)
	need_spawn = true

func add_explode(pos, delay):
	var ms_delay = 0.3 * delay / 100
	var timer = Timer.new()
	timer.set_one_shot(true)
	timer.connect("timeout", self, "do_explode", [pos])
	timer.set_wait_time(ms_delay)
	timer.set_timer_process_mode(Timer.TIMER_PROCESS_FIXED)
	timer.start()
	add_child(timer)

func do_explode(pos):
	var explode = explode_class.instance()
	explode.set_pos(pos)
	add_child(explode)