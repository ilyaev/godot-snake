extends "res://src/world/state/base.gd"


var vortex_class = preload('res://src/animation/level_transition.tscn')

func _init():
    name = 'NEXT_LEVEL_ANIMATION'

func do_on_enter():
    var vortex = vortex_class.instance()
    vortex.set_pos(scene.snake.head.get_pos())
    vortex.connect("finished", self, "anim_finished", [vortex])
    vortex.set_z(100)
    vortex.scene = scene
    scene.snake.world.add_child(vortex)

func _load_level():
    scene.map.apply_level(scene.current_level)
    if scene.current_level.get_model():
        scene.DQN.fromJSON("res://src/aimodels/" + scene.current_level.get_model())
    scene.restart_all()
    scene.fly_camera_to(scene.snake.head.get_pos())

func anim_finished(vortex):
    scene.snake.world.remove_child(vortex)
    scene.destroy_all()
    call_deferred('_load_level')

