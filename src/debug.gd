extends Node2D

onready var world = get_node("/root/world")
onready var map = get_node("/root/world/foreground_layer/walls")



func _ready():
	if world.show_debug:
		set_process(true)

func _draw():
	if !world.show_debug:
		return
	var snake = world.snake
	var snakes = world.snakes

	if snake.path.size() > 0:
		for cell in snake.path:
			draw_circle(map.map_to_screen(cell), 20, Color(1,0,0,0.5))

	for one_snake in snakes.get_children():
		if one_snake.is_in_group("foe") and one_snake.path.size() > 0:
			for cell in one_snake.path:
				draw_circle(map.map_to_screen(cell), 15, Color(0,0,1,0.5))

func _process(delta):
	update()