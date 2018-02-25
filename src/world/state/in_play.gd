extends "res://src/world/state/base.gd"

func _init():
    name = 'IN_PLAY'

func do_on_enter():
    ._update_stats()
    if scene.snake:
        scene.snake.set_target(scene.direction)


func ui_command(cmd):

    if cmd == 'left' and scene.direction.x > 0:
        return
    if cmd == 'right' and scene.direction.x < 0:
        return
    if cmd == 'up' and scene.direction.y > 0:
        return
    if cmd == 'down' and scene.direction.y < 0:
        return

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
