extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export var name = 'base'
export var max_food = 1
export var max_enemy = 3
export var model = 'DEFAULT'

func _ready():
	print("Level Loaded!")
	pass


func get_model():
	if get_node('academy') and get_node('academy').get_children().size() > 0:
		return get_node('academy').get_children()[0].model
	else:
		return model

func get_max_enemy():
	if get_node('academy') and get_node('academy').get_children().size() > 0:
		return get_node('academy').get_children()[0].max_enemy
	else:
		return max_enemy
