extends Node2D


var state setget set_state, get_state
var states_classes

func on_scene_enter():
    print("ON SCENE ENTER STUB!!!!")

func on_quit_request():
    print("REquest to quit")


func on_pause():
    print("Pause request")

func set_state(new_state, scene):
    state = states_classes[new_state]
    state.scene = scene
    state.do_on_enter()
    print("STATE: ", state.name, ' - ', new_state)

func get_state():
    print("GET STATE")
    return state