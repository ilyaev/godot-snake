extends Area2D

var snake = false
var experience = 0
var effect_type = 'Fruit'
var effect_state = 0
var effect_duration = -1
var active = true
var auto_anim = "show"
var loop = false
var action = 'Nothing'
var post_anim = ''
var map_pos = Vector2(-1,-1)

onready var animation = get_node("animation")
onready var timer = get_node("timer")
onready var sprite = get_node("sprite")
onready var world = get_node("/root/world")
onready var eaten_texture = preload("res://art/medium/snake_tail_1.png")

func _ready():
	active = true

	if auto_anim == "show":
		sprite.set_scale(Vector2(0,0))
		fall_down()

	animation.play(auto_anim)

	if post_anim:
		loop = true
		auto_anim = post_anim
	if loop:
		animation.connect("finished", self, "on_animation_finished")

	if action == 'SnakeBin':
		prepare_bin()

func prepare_bin():
	var timer = Timer.new()
	timer.set_one_shot(true)
	timer.connect("timeout", self, "open_bin", [timer])
	timer.set_wait_time(effect_duration)
	timer.set_timer_process_mode(Timer.TIMER_PROCESS_FIXED)
	add_child(timer)
	timer.start()


func open_bin(timer):
	timer.queue_free()
	if world.state_id == world.STATE_IN_PLAY or world.state_id == world.STATE_WAITING_TO_START:
		world.rain_snake(get_pos())
		if snake and !global.is_deleted(snake) and snake.has_method("spawn_food"):
			snake.spawn_food()
		else:
			destroy()

func get_map_pos():
	if !active:
		return Vector2(-1,-1)
	if map_pos.x < 0:
		map_pos = world.map.world_to_map(get_pos())
	return map_pos

func on_animation_finished():
	animation.play(auto_anim)

func destroy():
	active = false
	world.map.remove_food_from_map(get_pos())
	timer.set_wait_time(1.2)
	timer.start()
	animation.play_backwards("show")
	fly_up()

func fly_up():
	if sprite:
		sprite.set_modulate(Color(0, 0, 0, 0.5))

	var tween = Tween.new()
	tween.interpolate_property(self, "transform/pos", get_pos(), Vector2(get_pos().x + (randi() % 400 - 200), 0),  1.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.connect('tween_complete', self, "on_fall_tween_complete", [tween])
	add_child(tween)
	tween.start()

func fall_down():
	active = false
	var tween = Tween.new()
	tween.interpolate_property(self, "transform/pos", get_pos() - Vector2(0, get_pos().y), get_pos(),  0.7, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	tween.connect('tween_complete', self, "on_fall_tween_complete", [tween])
	add_child(tween)
	tween.start()

func on_fall_tween_complete(obj, key, tween):
	active = true
	tween.queue_free()

func _on_timer_timeout():
	queue_free()

func set_texture(texture):
	sprite.set_texture(texture)
