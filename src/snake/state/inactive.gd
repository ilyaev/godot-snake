extends "res://src/snake/state/base.gd"


func _init():
    name = 'SNAKE_STATE_INACTIVE'


func do_on_enter(_timeout = 0, _next_state = null):
    snake.active = false


func on_exit_state():
    print("RACTIVE")
    snake.active = true

func snake_collide():
    print("INVINCIBLE!")
    pass

func destroy():
    print("INVINCIBLE!!!")
    pass

func deactivate():
    print("INVINCIBLE!!")

func proxy_emit_signal(_signal, var1 = NULL, var2 = NULL):
    pass

func destroy_food():
    print("INVNCIBLE!!!!!")

func next_move():
    pass

func doShrink():
    print("INVINCIBLE!!!")
    pass