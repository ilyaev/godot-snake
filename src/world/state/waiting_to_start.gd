extends "res://src/world/state/base.gd"


func _init():
    name = 'WAITING_TO_START'

func do_on_enter():
    pass

func ui_command(cmd):
    ._snake_command(cmd)
    scene.set_state(scene.STATE_IN_PLAY, scene)
    .ui_command(cmd)

func process(delta):
    scene.camera.align_to(scene.snake.head.get_pos())