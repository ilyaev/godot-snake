extends Area2D

onready var animation = get_node('animation')
onready var tween = get_node("tween")
onready var map = get_node("/root/world/walls")
onready var world = get_node("/root/world")

var fly_to_pos
var do_unlock = true

func _ready():
	animation.play("appear")
	pass

func fly_to(pos):
	fly_to_pos = pos

func _on_Timer_timeout():
	animation.play("fly")
	tween.interpolate_property(self, "transform/pos", get_pos(), fly_to_pos, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func _on_tween_tween_complete( object, key ):
	if do_unlock:
		map.do_unlock_next(fly_to_pos)
		world.add_explode(fly_to_pos, 0.1)
	queue_free()
