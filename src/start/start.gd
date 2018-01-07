extends "res://src/base-scene.gd"


var width = 640 * 2
var height = 480 * 2
var original_zoom
var field_height

onready var camera = get_node("camera")
onready var ui = get_node("ui")

func _ready():
	field_height = height
	original_zoom = camera.get_zoom()
	size_changed()
	get_tree().get_root().connect("size_changed", self, "size_changed")
	ui.get_node("btn_start").set_default_cursor_shape(Control.CURSOR_POINTING_HAND)
	set_process(true)

func size_changed():
	var size = get_tree().get_root().get_children()[1].get_viewport_rect().size
	var scale = field_height / size.y
	var offset = Vector2(width / 2, height / 2)
	offset.x = max(size.x / 2, min(width / 2, size.x / 2)) * scale
	var space = size.x - width / scale
	offset.x = offset.x - max(0, (space / 2 * scale))
	camera.set_zoom(original_zoom * scale)
	camera.set_offset(offset)

func _process(delta):
	ui.get_node("start_in").set_text("Start in " + String(int(round(get_node("autostart").get_time_left()))) + " seconds")
	pass


func _on_button_pressed():
	print("on start")
	get_node("/root/global").start_game()
	# get_node("/root/global").tools()


func _on_tbtn_start_pressed():
	_on_button_pressed()


func _on_autostart_timeout():
	print("AUTOSTART!")
	_on_button_pressed()
