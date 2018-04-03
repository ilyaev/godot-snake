extends "res://src/base-scene.gd"

const NEW_LIFE_PER_POINTS = 5000

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
var food_drop_class = preload("res://src/food/food-drop.tscn")
var food_class = preload("res://src/food/food.tscn")
var last_id = 0
var need_spawn = false
var websocket
var fruits_config_class = preload("res://src/food/config_fruits.tscn")
var fruits_config
var level1_class = preload("res://src/levels/level1.tscn")
var level2_class = preload("res://src/levels/level2.tscn")
var level3_class = preload("res://src/levels/level3.tscn")
var level4_class = preload("res://src/levels/level4.tscn")
var level5_class = preload("res://src/levels/level5.tscn")
var current_level = false

onready var global = get_node("/root/global")

var levels = [
	level1_class,
	level2_class,
	level3_class,
	level4_class,
	level5_class
]

var current_level_number = 0
var initial_lifes = 3
var session_lifes = initial_lifes
var session_score = 0
var session_last_score = 0
var session_locks = 0


const STATE_WAITING_TO_START = 0
const STATE_IN_PLAY = 1
const STATE_DEATH_ANIMATION = 2
const STATE_NEXT_LEVEL_ANIMATION = 3
const STATE_GAME_OVER = 4
const STATE_DEBUG_MENU = 5

export var show_debug = true

onready var map = get_node("walls")
onready var snakes = get_node("snakes")
onready var foods = get_node("foods")
onready var camera = get_node("camera")
onready var hud = get_node("hud")
onready var tween = get_node("tween")

var DQN

func _ready():
	# hud.spawn_fader(0.5, true)
	states_classes = [
		preload("state/waiting_to_start.gd").new(),
		preload("state/in_play.gd").new(),
		preload("state/death_animation.gd").new(),
		preload("state/next_level_animation.gd").new(),
		preload("state/game_over.gd").new(),
		preload("state/menu_debug.gd").new()
	]


	DQN = global.DQN
	# DQN.fromJSON("res://src/aimodels/DEFAULT.json")

	set_state(STATE_WAITING_TO_START, self)
	load_level(levels[0].instance())
	fruits_config = fruits_config_class.instance()
	spawn_player_snake()
	spawn_enemy_snake()
	set_process(true)
	set_process_input(true)
	camera.connect("resize", self, "_on_world_resize")
	camera.size_changed()
	self.show_debug = false
	session_locks = map.get_lock_count()
	state._update_stats()
	#test_server()

func upload_score():
	var name = global.user.name
	global.post_score(String(session_score), name)

func load_level(level = false):
	if !level:
		level = level1_class.instance()

	if current_level:
		current_level.free()
		current_level = level
		set_state(STATE_NEXT_LEVEL_ANIMATION, self)
	else:
		current_level = level
		map.apply_level(level)
		if level.get_model():
			print("LOAD DQN: ", level.get_model() + ".json")
			DQN.fromJSON("res://src/aimodels/" + level.get_model() + ".json")

	session_locks = map.get_lock_count()
	state._update_stats()

func _on_world_resize(zoom, offset):
	hud.rescale(zoom, offset)

func on_scene_enter():
	pass

func on_scene_exit():
	# OS.print_all_resources('res://src/RS.txt')
	print("EXIT ROOT SCENE")

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
		global.back_to_start()
	if what == NOTIFICATION_PREDELETE:
		for one in states_classes:
			one.free()
		fruits_config.free()
		if current_level:
			current_level.free()

func _input(event):
	state.process_input(event)

func snake_next_level():
	current_level_number += 1
	if current_level_number >= levels.size():
		current_level_number = 0
	load_level(levels[current_level_number].instance())


func spawn_player_snake():
	snake = snake_class.instance()
	snake.id = next_id()
	snake.set_controller(snake.SNAKE_CONTROLLER_INPUT)
	snake.connect("collide", self, "snake_collide", [snake])
	snake.connect("after_move", self, "game_tick")
	snake.connect("next_level", self, "snake_next_level")
	snakes.add_child(snake)
	snake.relocate(map.map_to_screen(map.get_next_player_spawn_pos()))
	snake.spawn_food()
	# map.add_wall(snake.head.get_pos())
	map.add_wall_map(snake.head.start_position_map)

func spawn_enemy_snake(ignore_max = false):
	var spawn_pos = map.get_next_spawn_pos()
	if !map.free_around(spawn_pos, 2):
		return
	if !ignore_max and snakes.get_children().size() >= current_level.get_max_enemy() + 1:
		return
	var foe = snake_class.instance()
	# foe.set_controller(snake.SNAKE_CONTROLLER_AI_ASTAR)
	foe.set_controller(snake.SNAKE_CONTROLLER_AI_DQN)
	foe.controller.initialize([DQN])
	# foe.speed = rand_range(10, 10) / 100
	foe.add_to_group("foe")
	foe.id = next_id()
	snakes.add_child(foe)
	foe.relocate(map.map_to_screen(spawn_pos))
	foe.set_target(direction)
	foe.spawn_food()
	# map.add_wall(foe.head.get_pos())
	# map.add_wall_map(foe.head.start_position_map)
	foe.controller.find_route()


func spawn_static(key, pos, anim = ''):
	var food = food_class.instance()
	var fruit = fruits_config.get_node(key)
	if anim != '':
		food.auto_anim = anim
		food.loop = true
	food.add_to_group("static")
	foods.add_child(food)
	food.set_texture(fruit.get_texture())
	food.effect_type = fruit.type
	food.set_pos(map.map_to_screen(pos))

func rain_food(pos):
	for i in range(20):
		var drop = food_drop_class.instance()
		drop.set_pos(pos)
		drop.force = randi() % 1000 + 1000
		drop.ttl = 0.2 + randf() * 0.5
		drop.delay = randf()
		drop.direction = Vector2(randf() - 0.5, randf() * -1)
		drop.connect("finished", self, "rain_dropped", [drop])
		add_child(drop)

func rain_dropped(pos, drop):
	var mpos = map.world_to_map(pos)
	if map.cell_available(mpos):
		spawn_food(false, mpos, true)


func spawn_food(snake = false, food_pos = Vector2(-1,-1), ranf = false):
	var fruit = fruits_config.get_next_fruit()
	if !snake and !ranf:
		fruit = fruits_config.get_node('key')
	if ranf:
		fruit = fruits_config.get_node('grenade')

	var food = food_class.instance()
	food.add_to_group("food")

	food.experience = fruit.experience
	food.effect_type = fruit.type
	food.effect_state = fruit.state
	food.effect_duration = fruit.state_duration
	food.action = fruit.action
	food.post_anim = fruit.anim
	if snake:
		food.snake = snake
		snake.food = food

	randomize()

	var food_x = round(rand_range(0, map.maxX - 1))
	var food_y = round(rand_range(0, map.maxY - 1))

	while map.wall_map[map.get_cell_id(food_x, food_y)] == true:
		food_x = round(rand_range(0, map.maxX - 1))
		food_y = round(rand_range(0, map.maxY - 1))

	if food_pos.x > -1:
		food.set_pos(map.map_to_screen(food_pos))
	else:
		food.set_pos(map.map_to_screen(Vector2(food_x, food_y)))

	if fruit.type == 'Key':
		state.spawn_key_animation(food.get_pos())

	map.clear_food_map()
	for one in foods.get_children():
		if one.is_in_group("food") and one.active:
			map.add_food_to_map(one.get_pos())

	foods.add_child(food)
	food.set_texture(fruit.get_texture())

func game_tick():
	state.game_tick()

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
	get_node("snake_spawn_timer").set_wait_time(10)
	need_spawn = true


func add_explode(pos, delay, anim_class = explode_class, mode = ''):
	var ms_delay = 0.3 * delay / 100
	var timer = Timer.new()
	timer.set_one_shot(true)
	timer.connect("timeout", self, "do_explode", [pos, timer, anim_class, mode])
	timer.set_wait_time(ms_delay)
	timer.set_timer_process_mode(Timer.TIMER_PROCESS_FIXED)
	timer.start()
	add_child(timer)

func do_explode(pos, timer, anim_class, mode):
	timer.queue_free()
	var explode = anim_class.instance()
	explode.set_mode(mode)
	explode.set_pos(pos)
	add_child(explode)


func ui_command(cmd):
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

func restart_game():
	print("ESTST GAME - ")
	session_lifes = initial_lifes
	session_score = 0
	current_level = false
	load_level()
	spawn_player_snake()
	spawn_enemy_snake()
	fly_camera_to(snake.head.get_pos())
	direction.x = 0
	direction.y = 0

func destroy_all():
	for one in snakes.get_children():
		one.queue_free()
	snake = false
	direction.x = 0
	direction.y = 0
	map.clear_food_map()
	for one in foods.get_children():
		one.queue_free()

func restart_all():
	spawn_player_snake()
	spawn_enemy_snake()

func _on_tween_tween_complete( object, key ):
	set_state(STATE_WAITING_TO_START, self)



func do_debug_action():
	if state_id == STATE_DEBUG_MENU:
		pop_state()
	else:
		push_state()
		set_state(STATE_DEBUG_MENU, self)


func fetch_thread():
	for thread in _thread_pool:
		if !thread.is_active():
			return thread
	var new_thread = Thread.new()
	_thread_pool.append(new_thread)
	return new_thread

func query_action(controller_state, controller):

	controller.snake.calculating = true
	controller.snake.next_action = []

	var thread = fetch_thread()

	thread.start(self, '_query_action', [controller, controller_state, thread])

func _query_action(params):
	var controller = params[0]
	var controller_state = params[1]
	var thread = params[2]
	var action = {}
	var act_index = -1

	if controller and controller.has_method("queue_free") and controller.DQN:
		DQN.mutex.lock()
		act_index = DQN.act(controller_state)
		DQN.mutex.unlock()

	thread.wait_to_finish()

	if controller and controller.has_method("queue_free") and controller.DQN:
		action = controller.actions[act_index]
		controller.snake.next_action = [action]
		controller.snake.calculating = false
