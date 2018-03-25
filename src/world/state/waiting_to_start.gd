extends "res://src/world/state/base.gd"


var waited = 0

func _init():
    name = 'WAITING_TO_START'

func do_on_enter():
    waited = 0
    pass

func ui_command(cmd):
    ._snake_command(cmd)
    scene.set_state(scene.STATE_IN_PLAY, scene)
    .ui_command(cmd)

func process(delta):
    waited = waited + delta
    scene.camera.align_to(scene.snake.head.get_pos())
    if waited > 3:
        ui_command('right')