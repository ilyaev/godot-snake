extends Node

var snake
var name
var timeout = 0
var next_state = false
var timer


func _init():
    pass


func fixed_process(delta):
    var speed = snake.speed
    var base_speed = snake.base_speed
    var de_speed = (base_speed / speed)

    delta = delta * speed
    var real_delta = ( delta / de_speed )

    snake.all_time = snake.all_time + delta
    if snake.all_time >= (de_speed + delta) and snake.head.state == snake.head.STATE_INTWEEN:
        snake.head.state = snake.head.STATE_END
        snake.next_move()
        snake.speed = snake.next_speed
    else:
        snake.head.set_pos(snake.head.get_pos() + snake.head.current_target_direction * real_delta)
        for body in snake.tail.get_children():
            body.set_pos(body.get_pos() + body.current_target_direction * real_delta)


func next_level():
    snake.emit_signal('next_level')

func do_on_enter(_timeout = 0, _next_state = null):
    if _timeout > 0:
        timeout = _timeout
        next_state = _next_state
        run_timer()
    pass

func run_timer():
    if !timer:
        timer = Timer.new()
        timer.set_one_shot(true)
        timer.connect("timeout", self, "on_timer", [timer])
        timer.set_timer_process_mode(Timer.TIMER_PROCESS_FIXED)
        snake.add_child(timer)
    timer.stop()
    timer.set_wait_time(timeout)
    timer.start()

func on_exit_state():
    if timer:
        timer.stop()

func on_timer(timer):
    if next_state:
        snake.set_state(next_state)
    else:
        snake.set_state(snake.SNAKE_STATE_NORMAL)

func process(delta):
    pass

func on_animation_finished():
    if snake.animation.get_current_animation() == 'show':
        snake.ready_to_start()

func snake_collide():
    if !snake.is_moving():
        return

    if snake.is_in_group("foe"):
        snake.controller.find_route()
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
    # snake.map.remove_wall(snake.head.get_pos())
    snake.map.remove_wall_map(snake.head.target_position_map)
    for body in snake.tail.get_children():
        # snake.map.remove_wall(body.get_pos())
        snake.map.remove_wall_map(body.target_position_map)
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
        # snake.map.remove_wall(pos + back.target_direction)
        snake.map.remove_wall_map(back.target_position_map + back.target_direction_map)
        back.destroy()
        snake.world.add_explode(back.get_pos(), 1)
        snake.state.proxy_emit_signal("tail_shrink", pos)


func eat_food(one_food):
    snake.score += one_food.experience
    if !snake.is_in_group("foe"):
        snake.world.session_score += one_food.experience
    snake.doGrow()

    if one_food and one_food.snake:
        snake.spawn_food_by_snake(one_food.snake)
    else:
        one_food.destroy()

    if one_food.effect_state > 0 and snake.state_id != one_food.effect_state:
        snake.set_state(one_food.effect_state, one_food.effect_duration)

    # snake.set_speed(max(0.15, snake.start_speed - snake.speed_rate * snake.get_size()))

    if !snake.is_in_group('foe') and one_food.effect_type == 'Key':
        var lock_pos = snake.map.unlock_next()
        if lock_pos.x != -1:
            snake.world.state.play_unlock_one_animation(lock_pos)


func next_move():
    if !snake.active:
        return

    var last_body = snake.head
    var prelast_body = snake.head

    if snake.tail.get_children().size() > 0:
        last_body = snake.tail.get_children().back()

    if snake.tail.get_children().size() > 1:
        prelast_body = snake.tail.get_children()[snake.tail.get_children().size() - 2]

    # var tdiff = prelast_body.get_pos() - last_body.get_pos()
    var tdiff = prelast_body.target_position_map - last_body.target_position_map

    last_body.get_node("sprite").set_flip_h(tdiff.x < 0)
    last_body.set_rot(0)

    if tdiff.y < 0:
        last_body.set_rot(PI / 2)
    elif tdiff.y > 0:
        last_body.set_rot(-PI / 2)


    snake.snake_next_command()

    snake.head.get_node("sprite").set_flip_h(snake.head.target_direction_map.x < 0)
    snake.head.set_rot(0)

    if snake.head.target_direction_map.y < 0:
        snake.head.set_rot(PI/2)
    elif snake.head.target_direction_map.y > 0:
        snake.head.set_rot(-PI/2)

    snake.state.proxy_emit_signal("after_move")


