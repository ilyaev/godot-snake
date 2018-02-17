extends "res://src/world/state/base.gd"

var flash_class = preload('res://src/world/flash.tscn')
var go_class = preload("res://src/world/gameover.tscn")
var go_instance

func _init():
    name = 'GAME_OVER'
    set_process_input(true)

func do_on_enter():
    scene.destroy_all()
    var flash = flash_class.instance()
    flash.set_z(101)
    flash.get_node("sprite").set_modulate(Color(0,1,0,1))
    flash.set_scale(Vector2(scene.map.maxX * scene.map.snake_size, scene.map.maxY * scene.map.snake_size))
    scene.hud.add_child(flash)

    go_instance = go_class.instance()
    go_instance.set_z(102)
    scene.hud.add_to_center(go_instance)
    scene.hud.hide_controls()
    scene.hud.spawn_fader()
    pass

func process_input(event):
    if event.is_pressed():
        onFinished()

func onFinished():
    go_instance.queue_free()
    scene.hud.show_controls()
    scene.hud.release_fader()
    scene.global.back_to_start()