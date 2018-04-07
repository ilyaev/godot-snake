extends Node2D


onready var vortex = get_node('vortex')
onready var bits = get_node('bits')
onready var walls = get_node('walls')
onready var piece_class = preload('res://src/animation/vortex_piece.tscn')
onready var fader_class = preload('res://src/world/fader.tscn')
onready var flash_class = preload('res://src/world/flash.tscn')
onready var midlevel_class = preload('res://src/world/midlevel.tscn')

var wall_texture = preload("res://art/medium/sprite_11.png")

var target_positions = []
var tweens = []
var finished = 0
var scene
var old_pos
var time = 0
var half_size = 0
var fader_spawned = false
var fader = false
var to_finish = 0

signal finished

func clean_up():
	print("Cleanup vortex")

func _ready():
	apply_scene()
	vortex.init_target_positions(bits.get_children().size() * 4)
	build()
	old_pos = bits.get_pos()
	set_process(true)
	var flash = flash_class.instance()
	flash.set_z(101)
	flash.set_scale(Vector2(scene.map.maxX * scene.map.snake_size, scene.map.maxY * scene.map.snake_size))
	scene.hud.add_child(flash)
	pass

func spawn_midlevel():
	var midlevel = midlevel_class.instance()
	midlevel.set_z(102)
	midlevel.set_pos(scene.camera.size / 2)
	midlevel.score_value = scene.session_score
	midlevel.connect("oncontinue", self, "do_continue", [midlevel])
	scene.hud.add_to_center(midlevel)

func do_continue(midlevel):
	midlevel.queue_free()
	fader.reverse(0.5)
	emit_signal("finished")

func spawn_fader(ttl = 2):
	if fader_spawned:
		return
	fader_spawned = true
	fader = fader_class.instance()
	fader.set_z(101)
	fader.set_scale(scene.camera.size)
	fader.ttl = ttl
	scene.hud.add_child(fader)
	spawn_midlevel()
	pass

func _process(delta):
	time = time + delta
	var r = 0
	# var r = half_size * float(1) / float(time)
	r = half_size / 3
	bits.set_pos(old_pos + Vector2(rand_range(-r,r), 0))
	pass



func build():
	to_finish = bits.get_children().size()
	for one in bits.get_children():
		var timer = Timer.new()
		timer.set_one_shot(true)
		timer.connect("timeout", self, "do_proceed", [one, timer])
		timer.set_wait_time(randf() * 0.001)
		timer.set_timer_process_mode(Timer.TIMER_PROCESS_FIXED)
		add_child(timer)
		timer.start()
	for wall in walls.get_children():
		var tween = Tween.new()
		tween.interpolate_property(wall, "transform/pos", wall.get_pos(), Vector2(wall.get_pos().x,  scene.map.get_screen_height()), randf() * 3 + 2, Tween.TRANS_BOUNCE, Tween.EASE_OUT_IN)
		tween.connect('tween_complete', self, "on_wall_tween_complete", [wall, tween])
		add_child(tween)
		tween.start()
	pass

func on_wall_tween_complete(obj, key, one, tween):
	one.queue_free()
	tween.queue_free()

func do_proceed(one, timer):
	timer.queue_free()
	var tween = Tween.new()
	tween.interpolate_property(one, "transform/pos", one.get_pos(), one.get_pos() - Vector2(0,  rand_range(100, 300)), 2, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.connect('tween_complete', self, "on_tween_complete_pre", [one, tween])
	add_child(tween)
	tween.start()

func do_proceed_next(one, timer):
	timer.queue_free()
	var tween = Tween.new()
	tween.interpolate_property(one, "transform/pos", one.get_pos(), vortex.get_pos() + vortex.get_point(0), 0.5, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	tween.connect('tween_complete', self, "on_tween_complete", [one, tween])
	add_child(tween)
	tween.start()

func on_tween_complete_pre(obj, key, one, pretween):
	pretween.queue_free()
	var timer = Timer.new()
	timer.set_one_shot(true)
	timer.connect("timeout", self, "do_proceed_next", [one, timer])
	timer.set_wait_time(randf() * 2)
	timer.set_timer_process_mode(Timer.TIMER_PROCESS_FIXED)
	timer.start()
	add_child(timer)


func on_tween_complete(obj, key, one, tween):
	tween.queue_free()
	var follow = piece_class.instance()
	follow.set_scale(follow.get_scale() * (0.9 + (randf() * 0.5 - 0.25)))
	bits.remove_child(one)
	one.set_pos(Vector2(0,0))
	one.hide()
	follow.get_node('path/follow').add_child(one)
	var anim = follow.get_node('path/follow/animation')
	anim.connect("finished", self, "on_animation_end", [follow, one])
	anim.connect("animation_started", self, "on_animation_start", [one])
	anim.play('move')
	vortex.add_child(follow)
	spawn_fader(4)

func on_animation_start(name, obj):
	obj.show()

func on_animation_end(follow, one):
	one.queue_free()
	follow.queue_free()
	finished = finished + 1
	if finished == to_finish: #allbits.size():
		vortex.queue_free()
		# fader.reverse(0.5)

func apply_scene():
	half_size = scene.map.half_size

	for snake in scene.snakes.get_children():
		snake.active = false
		var sprite = snake.head.get_node("sprite")
		sprite.get_owner().remove_child(sprite)
		sprite.set_pos(snake.head.get_pos() - get_pos())
		bits.add_child(sprite)


		for body in snake.tail.get_children():
			var sprite = body.get_node("sprite")
			sprite.get_owner().remove_child(sprite)
			sprite.set_pos(body.get_pos() - get_pos())
			bits.add_child(sprite)

	for food in scene.foods.get_children():
		if food.effect_type != 'Static':
			var sprite = food.get_node("sprite")
			sprite.get_owner().remove_child(sprite)
			sprite.set_pos(food.get_pos() - get_pos())
			bits.add_child(sprite)
		else:
			food.call_deferred("destroy")

	for wall in scene.map.get_walls():
		var sprite = Sprite.new()
		sprite.set_texture(wall_texture)
		sprite.set_pos(wall - get_pos())
		walls.add_child(sprite)

	for pit in scene.map.get_bits():
		var timer = Timer.new()
		var ms_delay = 0.3 * rand_range(100, 500) / 100
		timer.set_one_shot(true)
		timer.connect("timeout", self, "do_explode", [pit, timer])
		timer.set_wait_time(ms_delay)
		timer.set_timer_process_mode(Timer.TIMER_PROCESS_FIXED)
		scene.add_child(timer)
		timer.start()


func do_explode(pit, timer):
	timer.queue_free()
	# scene.remove_child(timer)
	scene.add_explode(pit, 1 )
	scene.map.map.set_cellv(scene.map.world_to_map(pit), scene.map.get_grass_tile())
	scene.map.walls.set_cellv(scene.map.world_to_map(pit), -1) #scene.map.get_grass_tile())