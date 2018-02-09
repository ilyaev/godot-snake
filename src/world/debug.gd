extends Node2D

onready var world = get_node("/root/world")
onready var map = get_node("/root/world/walls")



func _ready():
	if world.show_debug:
		set_process(true)

func _draw():
	# draw_rect(Rect2(0,0,1000,1000), Color(0, 0, 0, 0.7))
	if !world.show_debug:
		return
	var snake = world.snake
	var snakes = world.snakes

	if snake and snake != null and weakref(snake).get_ref() and snake.path.size() > 0:
		for cell in snake.path:
			draw_circle(map.map_to_screen(cell), 20, Color(1,0,0,0.5))

	for one_snake in snakes.get_children():
		if one_snake.food:
			draw_line(one_snake.head.get_pos(), one_snake.food.get_pos(), Color(1,0,0,0.5), 5)
		if one_snake.is_in_group("foe") and one_snake.path.size() > 0:
			for cell in one_snake.path:
				draw_circle(map.map_to_screen(cell), 15, Color(0,0,1,0.5))


		draw_line(one_snake.head.get_pos(), one_snake.head.get_pos() + one_snake.current_direction, Color(0,0,1,1), 5)
		draw_line(one_snake.head.get_pos(), one_snake.head.get_pos() + one_snake.head.target_direction, Color(1,0,0,1), 5)

	for cellid in map.wall_map:
		if map.wall_map[cellid]:
			var pos = cellid.split('x')
			draw_circle(map.map_to_screen(Vector2(pos[0], pos[1])), 25, Color(0,0.4,0,1))

	for cellid in map.food_map:
		if map.food_map[cellid]:
			var pos = cellid.split(':')
			draw_circle(map.map_to_screen(Vector2(pos[0], pos[1])), 25, Color(0,0,0.4,1))


func _process(delta):
	update()