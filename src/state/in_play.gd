extends "res://src/state/base.gd"

func _init():
    name = 'IN_PLAY'

func do_on_enter():
    scene.snake.set_target(scene.direction)


func ui_command(cmd):
    scene.snake.set_target(scene.direction)
    .ui_command(cmd)

func process(delta):
    scene.camera.align_to(scene.snake.head.get_pos())