extends "res://src/world/state/base.gd"

var flash_class = preload('res://src/world/flash.tscn')
var go_class = preload("res://src/world/gameover.tscn")
var go_instance
var can_go = false


func _init():
    name = 'GAME_OVER'
    set_process_input(true)

func do_on_enter():
    ._update_stats()
    scene.destroy_all()
    var flash = flash_class.instance()
    flash.set_z(101)
    flash.get_node("sprite").set_modulate(Color(0,1,0,1))
    flash.set_scale(Vector2(scene.map.maxX * scene.map.snake_size, scene.map.maxY * scene.map.snake_size))
    scene.hud.add_child(flash)

    can_go = false

    go_instance = go_class.instance()
    go_instance.set_z(102)
    go_instance.score_value = scene.session_score
    scene.hud.add_to_center(go_instance)
    scene.hud.hide_controls()
    scene.hud.spawn_fader()

    var timer = Timer.new()
    var ms_delay = 2
    timer.set_one_shot(true)
    timer.connect("timeout", self, "unlock_exit", [timer])
    timer.set_wait_time(ms_delay)
    timer.set_timer_process_mode(Timer.TIMER_PROCESS_FIXED)
    scene.add_child(timer)
    timer.start()

    pass

func unlock_exit(timer):
    can_go = true
    timer.queue_free()

func process_input(event):
    if event.is_pressed() and can_go:
        onFinished()

func onFinished():
    go_instance.queue_free()
    scene.hud.show_controls()
    scene.hud.release_fader()
    scene.global.back_to_start()