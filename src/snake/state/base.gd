extends Node

var snake
var name


func _init():
    pass

func do_on_enter():
    print("SNAKE ENTER STATE: ", name)
    pass

func process(delta):
    pass

func on_animation_finished():
    if snake.animation.get_current_animation() == 'show':
        snake.ready_to_start()

func snake_collide():
    if !snake.is_moving():
        return

    if snake.is_in_group("foe"):
        snake.find_route()
        if snake.path.size() == 0:
            snake.destroy()
            snake.emit_signal("collide")
        else:
            snake.next_command()
    else:
        snake.destroy()
        snake.emit_signal("collide")

func deactivate():
    snake.active = false
    snake.head.deactivate()
    snake.map.remove_wall(snake.head.get_pos())
    for body in snake.tail.get_children():
        snake.map.remove_wall(body.get_pos())
        body.deactivate()

func destroy():
    snake.food.destroy()
    snake.deactivate()

    snake.world.add_explode(snake.head.get_pos(), 1)
    snake.head.destroy()
    for body in snake.tail.get_children():
        snake.world.add_explode(body.get_pos(), rand_range(0, 100))
        body.destroy()

    if snake.is_in_group("foe"):
        snake.queue_free()

func proxy_emit_signal(_signal, var1 = null, var2 = null):
    if typeof(var2) != TYPE_NIL:
        snake.emit_signal(_signal, var1, var1)
    elif typeof(var1) != TYPE_NIL:
        snake.emit_signal(_signal, var1)
    else:
        snake.emit_signal(_signal)

func destroy_food():
    snake.food.destroy()

func doShrink():
    if snake.tail.get_children().size() > 1:
        if snake.is_in_group("foe"):
            snake.tail.get_children()[snake.tail.get_children().size() - 2].set_texture(snake.world.enemy_snake_tail_texture)
        else:
            snake.tail.get_children()[snake.tail.get_children().size() - 2].set_texture(snake.world.snake_tail_texture)

        var back = snake.tail.get_children().back()
        var pos = back.get_pos()
        snake.map.remove_wall(pos + back.target_direction)
        back.destroy()
        snake.world.add_explode(back.get_pos(), 1)
        snake.state.proxy_emit_signal("tail_shrink", pos)