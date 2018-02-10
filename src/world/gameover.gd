extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal finished

func _ready():
	get_node("animator").play("show")
	pass


func _on_animator_finished():
	emit_signal("finished")
	pass # replace with function body
