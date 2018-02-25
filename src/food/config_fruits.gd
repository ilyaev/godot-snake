extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var pool = []

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func build_pool():
	var index = 0
	for one in get_children():
		if one.available:
			var count = one.rarity
			for ind in range(0, count):
				if one.type == 'Fruit':
					pool.append(index)
		index = index + 1

func get_next_fruit():
	if pool.size() == 0:
		build_pool()
	var rindex = round(rand_range(0, pool.size() - 1))
	return get_children()[pool[rindex]]