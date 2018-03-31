extends Node2D

export var force = 1000
export var direction = Vector2(0.4,-1)
export var ttl = 1

var gravity_acceleration = Vector2(0, 4)
var gravity_force = Vector2(0,1)
var velocity = Vector2(0,0)
var acceleration = Vector2(0,0)
var rot = 0
var age = 0
var delay = 0

signal finished

func _ready():
	velocity = direction * force
	rot = randf() * 4
	set_fixed_process(true)
	pass


func _fixed_process(delta):
	if delay > 0:
		delay = delay - delta
	else:
		show()
		age = age + delta
		set_pos(get_pos() + (velocity * delta))
		set_rot(get_rot() + rot * delta)
		acceleration = acceleration + gravity_acceleration
		velocity = velocity + acceleration
		if age >= ttl:
			emit_signal("finished", get_pos())
			queue_free()
	pass