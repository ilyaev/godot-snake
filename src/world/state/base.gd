extends Node

var scene
var name
var anim_unlock_one = preload("res://src/food/anim_unlock_one.tscn")


func _init():
    pass

func do_on_enter():
    pass

func ui_command(cmd):
    pass

func do_on_exit():
    pass

func process_input(event):
	if event.is_action_pressed("ui_right"):
		scene.ui_command('right')
	elif event.is_action_pressed("ui_left"):
		scene.ui_command('left')
	elif event.is_action_pressed("ui_up"):
		scene.ui_command('up')
	elif event.is_action_pressed("ui_down"):
		scene.ui_command('down')
	elif event.is_action_pressed("ui_select"):
		scene.do_debug_action()
	elif event.is_action_pressed("ui_focus_next") and global.ENV != 'prod':
        scene.show_debug = !scene.show_debug
	elif event.is_action_pressed("ui_cancel"):
        on_back_btn()
	elif event.is_action_pressed("ui_accept"):
		if global.ENV != 'prod' and scene.state_id != scene.STATE_DEBUG_MENU:
			scene.spawn_enemy_snake(true)

func on_back_btn():
    if scene.global.state == scene.global.APP_STATE_PLAY:
        scene.global.back_to_start()

func play_unlock_one_animation(fly_to_pos):
    var anim = anim_unlock_one.instance()
    anim.set_pos(scene.snake.head.get_pos())
    scene.get_node('debug').add_child(anim)
    anim.fly_to(fly_to_pos)

func spawn_key_animation(pos):
    var anim = anim_unlock_one.instance()
    anim.do_unlock = false
    anim.set_pos(pos)
    scene.get_node('debug').add_child(anim)
    anim.fly_to(pos)

func process(delta):
    pass

func game_tick():
    pass

func _snake_command(cmd):
    if cmd == "left":
        scene.direction.x = -scene.map.snake_size
        scene.direction.y = 0
    elif cmd == 'right':
        scene.direction.x = scene.map.snake_size
        scene.direction.y = 0
    elif cmd == 'up':
        scene.direction.x = 0
        scene.direction.y = -scene.map.snake_size
    elif cmd == 'down':
        scene.direction.x = 0
        scene.direction.y = scene.map.snake_size

func _update_stats():
    var last_score = scene.session_last_score
    if scene.snake:
        if scene.session_score - last_score >= scene.NEW_LIFE_PER_POINTS:
            scene.session_lifes = scene.session_lifes + 1
            scene.session_last_score = scene.session_score
        scene.hud.update_score(String(1 + scene.snake.tail.get_children().size()), String(scene.session_score))
        scene.hud.set_lifes(String(scene.session_lifes))
        scene.hud.set_locks(String(scene.session_locks))
        scene.hud.update_player_position(scene.snake.head.get_pos(), scene.camera.get_offset(), scene.map.world_to_map(scene.snake.head.get_pos()), scene.map.maxX, scene.map.maxY)