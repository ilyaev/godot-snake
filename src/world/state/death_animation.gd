extends "res://src/world/state/base.gd"

var flash_class = preload('res://src/world/flash.tscn')


func _init():
    name = 'DEATH_ANIMATION'

func process_input(event):
    pass

func do_on_enter():
    scene.session_lifes -= 1
    if scene.session_lifes <= 0:
        scene.set_state(scene.STATE_GAME_OVER, scene)
        scene.upload_score()
        return
    scene.restart_player()
    var flash = flash_class.instance()
    flash.set_z(101)
    flash.get_node("sprite").set_modulate(Color(1,0,0,1))
    flash.set_scale(Vector2(scene.map.maxX * scene.map.snake_size, scene.map.maxY * scene.map.snake_size))
    scene.hud.add_child(flash)
    ._update_stats()

    var timer = Timer.new()
    timer.set_one_shot(true)
    timer.connect("timeout", self, "do_fly", [timer])
    timer.set_wait_time(0.5)
    timer.set_timer_process_mode(Timer.TIMER_PROCESS_FIXED)
    scene.hud.add_child(timer)
    timer.start()

func do_fly(timer):
    timer.queue_free()
    scene.fly_camera_to(scene.snake.head.get_pos())