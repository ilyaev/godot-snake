extends "res://src/world/state/base.gd"


var vortex_class = preload('res://src/animation/level_transition.tscn')
var debug = false

func _init():
    name = 'NEXT_LEVEL_ANIMATION'

func process_input(event):
    pass

func do_on_enter():
    if debug:
        scene.destroy_all()
        call_deferred('_load_level')
        return

    scene.hud.hide_controls()
    var vortex = vortex_class.instance()
    vortex.set_pos(scene.snake.head.get_pos())
    vortex.connect("finished", self, "anim_finished", [vortex])
    vortex.set_z(100)
    vortex.scene = scene
    scene.snake.world.add_child(vortex)
    scene.snake.set_state(scene.snake.SNAKE_STATE_INACTIVE)
    for foe in scene.snake.world.snakes.get_children():
        foe.set_state(scene.snake.SNAKE_STATE_INACTIVE)


func _load_level():
    scene.map.apply_level(scene.current_level)
    if scene.current_level.get_model():
        scene.DQN.fromJSON("res://src/aimodels/" + scene.current_level.get_model())
    scene.restart_all()
    scene.session_locks = scene.map.get_lock_count()
    scene.state._update_stats()
    scene.fly_camera_to(scene.snake.head.get_pos())

func anim_finished(vortex):
    vortex.queue_free()
    scene.destroy_all()
    call_deferred('_load_level')
    scene.hud.show_controls()

