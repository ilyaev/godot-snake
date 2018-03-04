extends "state_base.gd"

var fader

func _init():
    name = "START_SETTINGS"

func _on_enter():
    fader = scene.fader_class.instance()
    fader.set_z(101)
    fader.target_black = 0.5
    fader.set_scale(Vector2(10000,10000))
    fader.ttl = 0.5
    scene.add_child(fader)
    scene.settings.show()

func on_faded():
    pass

func _on_exit():
    if fader:
        fader.reverse(0.2)
    scene.settings.hide()

func settings_pressed():
    scene.set_state(scene.STATE_NORMAL)

func settings_changed():
    settings_pressed()

func start_game():
    pass

func input(event):
    pass