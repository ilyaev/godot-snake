extends "res://src/base-scene.gd"

var snake
var direction = Vector2(0,0)
var snake_class = preload("res://src/snake/snake.tscn")
var snake_tail_texture = preload("res://art/medium/snake_tail.png")
var enemy_food_texture = preload("res://art/medium/sprite_03_1.png")
var enemy_snake_tail_texture = preload("res://art/medium/snake_tail_1.png")
var snake_body_texture = preload("res://art/medium/sprite_01.png")
var enemy_snake_body_texture = preload("res://art/medium/sprite_01_1.png")
var enemy_head_texture = preload("res://art/medium/sprite_02_1.png")
var explode_class = preload("res://src/particles/explode.tscn")
var body_class = preload("res://src/snake/body.tscn")
var food_class = preload("res://src/food/food.tscn")
var last_id = 0
var need_spawn = false
var websocket
var fruits_config_class = preload("res://src/food/config_fruits.tscn")
var fruits_config

const STATE_WAITING_TO_START = 0
const STATE_IN_PLAY = 1
const STATE_DEATH_ANIMATION = 2

export var show_debug = true

onready var map = get_node("walls")
onready var snakes = get_node("snakes")
onready var foods = get_node("foods")
onready var camera = get_node("camera")
onready var hud = get_node("hud")
onready var tween = get_node("tween")

func _ready():

	states_classes = [
		preload("state/waiting_to_start.gd").new(),
		preload("state/in_play.gd").new(),
		preload("state/death_animation.gd").new()
	]

	set_state(STATE_WAITING_TO_START, self)

	fruits_config = fruits_config_class.instance()

	spawn_player_snake()
	spawn_enemy_snake()
	set_process(true)
	set_process_input(true)
	camera.connect("resize", self, "_on_world_resize")
	camera.size_changed()
	self.show_debug = false
	#test_server()

func _on_world_resize(zoom, offset):
	hud.rescale(zoom, offset)

func on_scene_enter():
	print("Enter GAME!")

func test_server():
	print('TEST SERVER')
	websocket = preload('res://src/websocket.gd').new(self)
	#websocket.start('godot-snake-server.herokuapp.com',80)
	websocket.start('localhost', 3000)
	websocket.set_reciever(self,'_on_message_recieved')
	websocket.send("Hi server")


func _on_message_recieved(msg):
	print("REC: ", msg)
	websocket.disconnect()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		print("ANDR _ BACK")

func _input(event):
	if event.is_action_pressed("ui_right"):
		ui_command('right')
	elif event.is_action_pressed("ui_left"):
		ui_command('left')
	elif event.is_action_pressed("ui_up"):
		ui_command('up')
	elif event.is_action_pressed("ui_down"):
		ui_command('down')
	elif event.is_action_pressed("ui_accept"):
		#get_tree().set_pause(true)
		#get_node("/root/global").back_to_start()
		if snake.state_id == snake.SNAKE_STATE_NORMAL:
			snake.set_state(snake.SNAKE_STATE_INVINCIBLE)
		else:
			snake.set_state(snake.SNAKE_STATE_NORMAL)
	elif event.is_action_pressed("ui_focus_next"):
		self.show_debug = !self.show_debug


func spawn_player_snake():
	snake = snake_class.instance()
	snake.id = next_id()
	snake.connect("collide", self, "snake_collide", [snake])
	snake.connect("after_move", self, "game_tick")
	snakes.add_child(snake)
	snake.relocate(map.map_to_screen(Vector2(2, 2)))
	snake.spawn_food()
	map.add_wall(snake.head.get_pos())

func spawn_enemy_snake():
	var foe = snake_class.instance()
	foe.speed = rand_range(5, 50) / 100
	foe.add_to_group("foe")
	foe.id = next_id()
	snakes.add_child(foe)
	foe.relocate(map.map_to_screen(map.get_next_spawn_pos()))
	foe.set_target(direction)
	foe.spawn_food()
	map.add_wall(foe.head.get_pos())
	foe.find_route()


func spawn_food(snake):
	var fruit_index = rand_range(0, fruits_config.get_children().size())
	var fruit = fruits_config.get_children()[fruit_index]
	var food = food_class.instance()
	food.add_to_group("food")
	foods.add_child(food)
	food.set_texture(fruit.get_texture())
	food.experience = fruit.experience
	food.snake = snake
	snake.food = food

	randomize()

	var food_x = round(rand_range(0, map.maxX - 1))
	var food_y = round(rand_range(0, map.maxY - 1))

	while map.wall_map[map.get_cell_id(food_x, food_y)] == true:
		food_x = round(rand_range(0, map.maxX - 1))
		food_y = round(rand_range(0, map.maxY - 1))

	food.set_pos(map.map_to_screen(Vector2(food_x, food_y)))

func game_tick():
	if need_spawn:
		need_spawn = false
		spawn_enemy_snake()
	hud.update_score(String(1 + snake.tail.get_children().size()), String(snake.score))
	hud.update_player_position(snake.head.get_pos(), camera.get_offset(), map.world_to_map(snake.head.get_pos()), map.maxX, map.maxY)

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
	set_state(STATE_DEATH_ANIMATION, self)

func _process(delta):
	state.process(delta)

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


func ui_command(cmd):
	if cmd == "left":
		direction.x = -map.snake_size
		direction.y = 0
	elif cmd == 'right':
		direction.x = map.snake_size
		direction.y = 0
	elif cmd == 'up':
		direction.x = 0
		direction.y = -map.snake_size
	elif cmd == 'down':
		direction.x = 0
		direction.y = map.snake_size

	state.ui_command(cmd)

func fly_camera_to(pos):
	var from = camera.get_offset()
	var to = camera.calculate_offset(pos)
	if (from-to).length() != 0:
		tween.interpolate_method(camera, "set_offset", camera.get_offset(), camera.calculate_offset(pos), 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT )
		tween.start()
	else:
		_on_tween_tween_complete(camera, "set_offset")


func restart_player():
	snake.queue_free()
	snake = false
	spawn_player_snake()
	direction.x = 0
	direction.y = 0

func _on_tween_tween_complete( object, key ):
	set_state(STATE_WAITING_TO_START, self)
