extends "base.gd"

func _init():
    name = 'Input'

func next_command():
    snake.set_target(snake.world.direction)
    snake.further_command()

