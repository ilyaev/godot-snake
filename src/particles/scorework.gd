extends Node2D

var key_texture = preload("res://art/sprites/keyRed.png")

func _ready():
	pass


func set_mode(mode):
	if mode == 'key' or mode == 'unlocked':
		get_node("particles").set_texture(key_texture)
	if mode == 'unlocked':
		get_node("particles").set_color(Color(0,1,0,0.5))

func _on_Timer_timeout():
	var tween = Tween.new()
	tween.interpolate_property(self, "visibility/opacity", 1, 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	tween.connect("tween_complete", self, "on_finish", [tween])
	add_child(tween)

func on_finish(obj, key, tween):
	tween.queue_free()
	queue_free()
