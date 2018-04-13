extends Node

var name
var scene

func _init():
    pass

func _on_enter():
    pass

func _on_exit():
    pass

func settings_pressed():
    scene.set_state(scene.STATE_SETTINGS)
    pass

func settings_changed():
    pass

func start_game():
    scene.spawn_fader(0.5)

func input(event):
    if event.is_action_pressed("ui_cancel"):
        scene.get_tree().quit()
    if event.type == InputEvent.KEY && event.is_pressed():
        scene._on_tbtn_start_pressed()


