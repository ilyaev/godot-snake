extends Node2D


onready var vortex = get_node('vortex')
onready var bits = get_node('bits')
onready var piece_class = preload('res://src/animation/vortex_piece.tscn')

var target_positions = []
var tweens = []
var allbits = []
var finished = 0
var scene

signal finished

func _ready():
	apply_scene()
	vortex.init_target_positions(bits.get_children().size() * 4)
	build()
	pass


func build():
	var index = 0
	for one in bits.get_children():
		allbits.append(one)
		var timer = Timer.new()
		timer.set_one_shot(true)
		timer.connect("timeout", self, "do_proceed", [index, timer])
		timer.set_wait_time(randf() * 0.001)
		timer.set_timer_process_mode(Timer.TIMER_PROCESS_FIXED)
		timer.start()
		add_child(timer)
		index = index + 1
	pass

func do_proceed(index, timer):
	remove_child(timer)
	var tween = Tween.new()
	var one = allbits[index]
	tween.interpolate_property(one, "transform/pos", one.get_pos(), one.get_pos() - Vector2(0,  rand_range(100, 300)), 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.connect('tween_complete', self, "on_tween_complete_pre", [index, one, tween])
	add_child(tween)
	tween.start()

func do_proceed_next(index, timer):
	remove_child(timer)
	var tween = Tween.new()
	var one = allbits[index]
	tween.interpolate_property(one, "transform/pos", one.get_pos(), vortex.get_pos() + vortex.get_point(0), 0.5, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	tween.connect('tween_complete', self, "on_tween_complete", [index, one, tween])
	add_child(tween)
	tween.start()

func on_tween_complete_pre(obj, key, index, one, pretween):
	remove_child(pretween)
	var timer = Timer.new()
	timer.set_one_shot(true)
	timer.connect("timeout", self, "do_proceed_next", [index, timer])
	timer.set_wait_time(randf() * 0.5)
	timer.set_timer_process_mode(Timer.TIMER_PROCESS_FIXED)
	timer.start()
	add_child(timer)


func on_tween_complete(obj, key, index, one, tween):
	remove_child(tween)
	var follow = piece_class.instance()
	bits.remove_child(one)
	one.set_pos(Vector2(0,0))
	one.hide()
	follow.get_node('path/follow').add_child(one)
	var anim = follow.get_node('path/follow/animation')
	anim.connect("finished", self, "on_animation_end", [index, follow])
	anim.connect("animation_started", self, "on_animation_start", [one])

	anim.play('move')
	vortex.add_child(follow)

func on_animation_start(name, obj):
	obj.show()

func on_animation_end(index, follow):
	vortex.remove_child(follow)
	finished = finished + 1
	if finished == allbits.size():
		emit_signal("finished")

func apply_scene():
	for bit in bits.get_children():
		bits.remove_child(bit)

	for snake in scene.snakes.get_children():
		var sprite = snake.head.get_node("sprite")
		sprite.get_owner().remove_child(sprite)
		sprite.set_pos(snake.head.get_pos())
		bits.add_child(sprite)
		for body in snake.tail.get_children():
			var sprite = body.get_node("sprite")
			sprite.get_owner().remove_child(sprite)
			sprite.set_pos(body.get_pos())
			bits.add_child(sprite)
