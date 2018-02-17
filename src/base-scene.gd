extends Node2D


var state setget set_state, get_state
var state_id
var states_classes
var state_stack = []

func on_scene_enter():
    print("ON SCENE ENTER STUB!!!!")

func on_quit_request():
    print("REquest to quit")


func on_pause():
    print("Pause request")

func set_state(new_state, scene):
    if state and state.has_method("do_on_exit"):
        state.do_on_exit()
    state_id = new_state
    state = states_classes[new_state]
    print("SET STATE - ", state.name)
    state.scene = scene
    state.do_on_enter()

func get_state():
    return state

func push_state():
    state_stack.push_front(state_id)

func pop_state():
    if state_stack.size() <= 0:
        return
    var next_id = state_stack[0]
    state_stack.pop_front()
    set_state(next_id, state.scene)