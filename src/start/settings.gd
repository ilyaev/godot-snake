extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

onready var dpad = get_node("panel/cb_dpad")
onready var slider = get_node("panel/cb_slider")
onready var global = get_node("/root/global")

const CONTROL_DPAD = "0"
const CONTROL_SLIDER = "1"

var control_mode = CONTROL_DPAD
var settings_file = "user://settings.json"

signal changed

func _ready():
	load_settings()
	sync_cbs()

func sync_cbs():
	dpad.set_pressed(control_mode == CONTROL_DPAD)
	slider.set_pressed(control_mode == CONTROL_SLIDER)
	save_settings()
	global.set_control_style(control_mode)

func save_settings():
	var settings = File.new()
	settings.open(settings_file, File.WRITE)
	settings.store_line(control_mode)
	settings.close()

func load_settings():
	var settings = File.new()
	if not settings.file_exists(settings_file):
		control_mode = CONTROL_DPAD
	else:
		settings.open(settings_file, File.READ)
		var line = settings.get_line()
		control_mode = line
		settings.close()

func _on_cb_dpad_pressed():
	control_mode = CONTROL_DPAD
	sync_cbs()
	notify()


func _on_cb_slider_pressed():
	control_mode = CONTROL_SLIDER
	sync_cbs()
	notify()

func notify():
	emit_signal("changed")
