extends "res://src/world/state/base.gd"

var flash_class = preload('res://src/world/flash.tscn')
var go_class = preload("res://src/world/gameover.tscn")


func _init():
    name = 'GAME_OVER'

func do_on_enter():
    scene.destroy_all()
    var flash = flash_class.instance()
    flash.set_z(101)
    flash.get_node("sprite").set_modulate(Color(0,1,0,1))
    flash.set_scale(Vector2(scene.map.maxX * scene.map.snake_size, scene.map.maxY * scene.map.snake_size))
    scene.hud.add_child(flash)

    var go = go_class.instance()
    scene.hud.add_child(go)
    go.connect("finished", self, "onFinished", [go, scene])

    pass

func onFinished(go, scene):
    go.queue_free()
    scene.restart_game()