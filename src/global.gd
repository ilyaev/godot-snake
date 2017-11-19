extends Node

var current_scene = null

const APP_STATE_START_SCREEN = 0
const APP_STATE_PLAY = 1

var state = APP_STATE_START_SCREEN

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child( root.get_child_count() -1 )
	current_scene.on_scene_enter()
	print("Current sc", current_scene)

func goto_scene(path):
	call_deferred("_deferred_goto_scene",path)

func _notification(what):
	pass

func start_game():
	state = APP_STATE_PLAY
	goto_scene("res://src/world/root.tscn")

func back_to_start():
	state = APP_STATE_START_SCREEN
	goto_scene("res://src/start/start.tscn")

func _deferred_goto_scene(path):
	current_scene.free()
	var s = ResourceLoader.load(path)
	current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene( current_scene )
	current_scene.on_scene_enter()