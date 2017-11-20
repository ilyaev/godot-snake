extends "res://src/snake/state/base.gd"


func _init():
    name = 'SNAKE_STATE_INVINCIBLE'


func do_on_enter():
    .do_on_enter()
    if !snake.animation.is_playing():
        snake.animation.play("blink")

func on_animation_finished():
    .on_animation_finished()
    var clip = snake.animation.get_current_animation()
    if clip == 'show' || clip == 'blink':
        snake.animation.play("blink")

func snake_collide():
    print("INVINCIBLE!")
    pass

func destroy():
    print("INVINCIBLE!!!")
    pass

func deactivate():
    print("INVINCIBLE!!")

func proxy_emit_signal(_signal, var1 = NULL, var2 = NULL):
    if _signal == 'collide':
        return
    .proxy_emit_signal(_signal, var1, var2)

func destroy_food():
    print("INVNCIBLE!!!!!")