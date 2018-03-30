extends "base.gd"

var old_speed = 0

func _init():
    name = 'FLASH'

func do_on_enter(_timeout = 0, _next_state = null):
    .do_on_enter(_timeout, _next_state)

    old_speed = snake.speed
    snake.set_speed(1.5)
    if snake.head.get_node("sprite"):
        snake.head.get_node("sprite").set_modulate(Color(1,0,0))

func on_exit_state():
    snake.set_speed(old_speed)
    if snake.head.get_node("sprite"):
        snake.head.get_node("sprite").set_modulate(Color(1,1,1))
