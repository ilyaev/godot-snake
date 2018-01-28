extends Node

var scene
var name
var anim_unlock_one = preload("res://src/food/anim_unlock_one.tscn")


func _init():
    pass

func do_on_enter():
    pass

func ui_command(cmd):
    print("UI CMD - ", cmd, ' state: ', name)
    pass

func play_unlock_one_animation(fly_to_pos):
    var anim = anim_unlock_one.instance()
    anim.set_pos(scene.snake.head.get_pos())
    scene.add_child(anim)
    anim.fly_to(fly_to_pos)

func spawn_key_animation(pos):
    var anim = anim_unlock_one.instance()
    anim.do_unlock = false
    anim.set_pos(pos)
    scene.add_child(anim)
    anim.fly_to(pos)

func process(delta):
    pass