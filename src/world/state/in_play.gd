extends "res://src/world/state/base.gd"

func _init():
    name = 'IN_PLAY'

func do_on_enter():
    ._update_stats()
    if scene.snake:
        scene.snake.set_target(scene.direction)


func ui_command(cmd):

    var dir = scene.snake.immediate_direction

    if cmd == 'left' and dir.x > 0:
        return
    if cmd == 'right' and dir.x < 0:
        return
    if cmd == 'up' and dir.y > 0:
        return
    if cmd == 'down' and dir.y < 0:
        return


    var old_dir = scene.direction

    ._snake_command(cmd)

    # var next_cell = scene.map.world_to_map(scene.snake.head.get_pos() + dir)
    var pronext_cell = scene.map.world_to_map(scene.snake.head.start_position + scene.direction + scene.snake.head.target_direction)
    var not_in_map = false
    if pronext_cell.x < 0 or pronext_cell.y < 0 or pronext_cell.x > scene.map.maxX - 1 or pronext_cell.y > scene.map.maxY - 1:
        not_in_map = true

    if not_in_map or (cmd != scene.snake.current_command and scene.map.wall_map[scene.map.get_cell_id(pronext_cell.x, pronext_cell.y)]):
        scene.direction = old_dir
        return


    if scene.snake:
        scene.snake.current_command = cmd
        scene.snake.set_target(scene.direction)
    .ui_command(cmd)


func process(delta):
    if scene.snake:
        scene.camera.align_to(scene.snake.head.get_pos())

func game_tick():
    if scene.need_spawn:
        scene.need_spawn = false
        scene.spawn_enemy_snake()
    ._update_stats()
