extends "base.gd"

var old_speed = 0
var tween

func _init():
    name = 'FLASH'

func do_on_enter(_timeout = 0, _next_state = null):
    .do_on_enter(_timeout, _next_state)

    if !tween:
        tween = Tween.new()
        snake.add_child(tween)

    old_speed = snake.speed

    set_speed(snake.speed / 2)

func on_exit_state():
    set_speed(old_speed)

func set_speed(speed_to):
    tween.stop_all()
    tween.interpolate_method(snake, "set_speed", snake.speed, speed_to, 1, Tween.TRANS_SINE, Tween.EASE_IN_OUT )
    tween.start()
