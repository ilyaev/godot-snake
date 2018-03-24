extends Area2D

var snake = false
var experience = 0
var effect_type = 'Fruit'
var effect_state = 0
var effect_duration = -1
var active = true
var auto_anim = "show"
var loop = false

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
	if loop:
		animation.connect("finished", self, "on_animation_finished")

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
	sprite.set_modulate(Color(0, 0, 0, 0.5))

	var tween = Tween.new()
	tween.interpolate_property(self, "transform/pos", get_pos(), Vector2(get_pos().x + (randi() % 400 - 200), 0),  1.2, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	tween.connect('tween_complete', self, "on_fall_tween_complete", [tween])
	add_child(tween)
	tween.start()

func fall_down():
	var tween = Tween.new()
	tween.interpolate_property(self, "transform/pos", get_pos() - Vector2(0, get_pos().y), get_pos(),  0.7, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	tween.connect('tween_complete', self, "on_fall_tween_complete", [tween])
	add_child(tween)
	tween.start()

func on_fall_tween_complete(obj, key, tween):
	tween.queue_free()

func _on_timer_timeout():
	queue_free()

func set_texture(texture):
	sprite.set_texture(texture)
