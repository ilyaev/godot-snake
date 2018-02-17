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
        return
    scene.restart_player()
    scene.fly_camera_to(scene.snake.head.get_pos())
    var flash = flash_class.instance()
    flash.set_z(101)
    flash.get_node("sprite").set_modulate(Color(1,0,0,1))
    flash.set_scale(Vector2(scene.map.maxX * scene.map.snake_size, scene.map.maxY * scene.map.snake_size))
    scene.hud.add_child(flash)