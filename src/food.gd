extends Area2D

var snake = false

onready var animation = get_node("animation")
onready var timer = get_node("timer")
onready var sprite = get_node("sprite")

func _ready():
	sprite.set_scale(Vector2(0,0))
	animation.play("show")

func destroy():
	timer.set_wait_time(animation.get_animation("show").get_length())
	timer.start()
	animation.play_backwards("show")

func _on_timer_timeout():
	queue_free()

func set_texture(texture):
	sprite.set_texture(texture)
