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

    # var next_cell = scene.map.world_to_map(scene.snake.head.get_pos() + scene.direction)
    # if scene.map.wall_map[scene.map.get_cell_id(next_cell.x, next_cell.y)]:
    #     print("WALLL!!!")

    ._snake_command(cmd)
    if scene.snake:
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
