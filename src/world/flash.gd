extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("animator").play("show")
	pass


func _on_animator_finished():
	print("FLASH QUE FREE")
	call_deferred("queue_free")
	# queue_free()
