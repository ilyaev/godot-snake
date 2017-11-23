extends "base.gd"

var directions = []

func _init():
    name = 'AI_Astar'
    directions = [Vector2(-1, 0), Vector2(1,0), Vector2(0, -1), Vector2(0,1)]

func _set_path(new_path):
    snake.commands.clear()
    var cur_pos = snake.map.world_to_map(snake.head.get_pos())
    for node in new_path:
        snake.commands.append(Vector2(node.x, node.y) - cur_pos)
        cur_pos = Vector2(node.x, node.y)
    snake.path = new_path

func find_route():
    snake.clear_path()
    var default_path = []
    for direction in directions:
        if snake.path.size() == 0 and !snake.map.is_wall_world(snake.head.get_pos() + direction * snake.map.snake_size):
            if default_path.size() == 0:
                default_path.append(snake.map.world_to_map(snake.head.get_pos() + direction * snake.map.snake_size))
            _set_path(snake.map.get_path(snake.map.world_to_map(snake.head.get_pos() + direction * snake.map.snake_size), snake.map.world_to_map(snake.food.get_pos())))
    if snake.path.size() == 0:
        if default_path.size() > 0:
            _set_path([Vector3(default_path[0].x, default_path[0].y, 0)])

func next_command():
    if snake.commands.size() > 0:
        var command = snake.commands[0]
        snake.commands.pop_front()
        if snake.path.size() > 0:
            snake.path.remove(0)
        if !snake.map.is_wall_world(snake.head.get_pos() + command * snake.map.snake_size):
            snake.set_target(command * snake.map.snake_size)
        else:
            find_route()
            next_command()

func new_food_arrived():
    find_route()
    next_command()

func new_food_arrived_deferred():
    snake.search_food = true