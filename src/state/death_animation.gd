extends "res://src/state/base.gd"


func _init():
    name = 'DEATH_ANIMATION'

func do_on_enter():
    scene.restart_player()
    scene.fly_camera_to(scene.snake.head.get_pos())