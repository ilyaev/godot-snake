extends "state_base.gd"

func _init():
    name = "START_NORMAL"

func _on_enter():
    print("ENTER NORAML STATE")

func _on_exit():
    print("EXIT NORMAL STATE")