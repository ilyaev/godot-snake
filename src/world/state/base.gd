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