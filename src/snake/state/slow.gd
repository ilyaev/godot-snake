extends "base.gd"

var old_speed = 0

func _init():
    name = 'SLOW'

func do_on_enter(_timeout = 0, _next_state = null):
    .do_on_enter(_timeout, _next_state)
    old_speed = snake.speed
    snake.set_speed(0.5)
    if snake.head and snake.head.get_node("sprite"):
        snake.head.get_node("sprite").set_modulate(Color(0,1,0))

func on_exit_state():
    if snake.head and !global.is_deleted(snake) and !global.is_deleted(snake.head) and snake.head.get_node("sprite"):
        snake.head.get_node("sprite").set_modulate(Color(1,1,1))
    snake.set_speed(1)
