extends Area2D

var snake = false
var experience = 0
var effect_type = 'Fruit'
var effect_state = 0
var effect_duration = -1
var active = true

onready var animation = get_node("animation")
onready var timer = get_node("timer")
onready var sprite = get_node("sprite")
onready var world = get_node("/root/world")

func _ready():
	active = true
	sprite.set_scale(Vector2(0,0))
	animation.play("show")

func destroy():
	active = false
	world.map.remove_food_from_map(get_pos())
	timer.set_wait_time(animation.get_animation("show").get_length())
	timer.start()
	animation.play_backwards("show")

func _on_timer_timeout():
	queue_free()

func set_texture(texture):
	sprite.set_texture(texture)
