extends Node2D

onready var dpad = get_node("panel/cb_dpad")
onready var slider = get_node("panel/cb_slider")
onready var global = get_node("/root/global")
onready var nickname = get_node("panel/nickname")

const CONTROL_DPAD = "0"
const CONTROL_SLIDER = "1"

var control_mode = CONTROL_DPAD
var settings_file = "user://settings.json"

var validation_exp = RegEx.new()

signal changed

func _init():
	validation_exp.compile("[A-Za-z]|\\d")

func _ready():
	global.connect("rpc_response", self, "on_rpc_response")
	load_settings()
	sync_cbs()

func on_rpc_response(response, command):
	pass
	# print("RPC: CMD: ", command, ' - ', response)

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
		control_mode = CONTROL_SLIDER
	else:
		settings.open(settings_file, File.READ)
		var line = settings.get_line()
		control_mode = line
		settings.close()
	nickname.set_text(global.user.name)

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


func _on_LineEdit_text_changed( text ):
	var result = ""
	var len = text.length()
	for one in range(0, len):
		if validation_exp.find(text[one]) == 0:
			result = result + text[one]
	nickname.set_text(result)
	nickname.set_cursor_pos(result.length())


func _on_TouchScreenButton_pressed():
	global.update_name(nickname.get_text())
	notify()
