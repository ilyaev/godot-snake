extends "res://src/base-scene.gd"


var width = 640 * 2
var height = 480 * 2
var original_zoom
var field_height
var fader_spawned = false
var fader = false
var own_state
var own_state_id
var own_states_classes = [
	preload("state_normal.gd").new(),
	preload("state_settings.gd").new()
]
var btns_enabled = false

onready var camera = get_node("camera")
onready var ui = get_node("ui")
onready var player = get_node("ui/animation")
onready var settings = get_node("ui/settings")
onready var fader_class = preload('res://src/world/fader.tscn')
onready var border_left = get_node("border_left")
onready var border_right = get_node("border_right")

const STATE_NORMAL = 0
const STATE_SETTINGS = 1

func _ready():
	btns_enabled = false
	field_height = height
	original_zoom = camera.get_zoom()
	size_changed()
	get_tree().get_root().connect("size_changed", self, "size_changed")
	ui.get_node("btn_start").set_default_cursor_shape(Control.CURSOR_POINTING_HAND)
	ui.get_node("btn_settings").set_default_cursor_shape(Control.CURSOR_POINTING_HAND)
	set_process(true)
	set_process_input(true)
	set_state(STATE_NORMAL)


func set_state(new_state):
	if own_state and own_state.has_method("_on_exit"):
		own_state._on_exit()
	own_state_id = new_state
	own_state = own_states_classes[new_state]
	own_state.scene = self
	own_state._on_enter()

func _input(event):
	own_state.input(event)

func size_changed():
	var size = get_tree().get_root().get_children()[1].get_viewport_rect().size
	var scale = field_height / size.y
	var offset = Vector2(width / 2, height / 2)
	offset.x = max(size.x / 2, min(width / 2, size.x / 2)) * scale
	var space = size.x - width / scale
	offset.x = offset.x - max(0, (space / 2 * scale))
	camera.set_zoom(original_zoom * scale)
	camera.set_offset(offset)


	if size.x > width:
		border_left.set_scale(Vector2(space, size.y * scale * 2))
		border_left.set_pos(Vector2(-space/2, 0))
		border_left.show()

		border_right.set_scale(Vector2(space, size.y * scale * 2))
		border_right.set_pos(Vector2(width + space / 2, 0))
		border_right.show()
	else:
		border_left.hide()
		border_right.hide()

func _process(delta):
	ui.get_node("start_in").set_text("Start in " + String(int(round(get_node("autostart").get_time_left()))) + " seconds")
	pass


func _on_button_pressed():
	own_state.start_game()


func _on_tbtn_start_pressed():
	if btns_enabled:
		_on_button_pressed()


func _on_autostart_timeout():
	_on_button_pressed()


func _on_animation_finished():
	player.play("snake")


func _on_animation1_finished():
	get_node("ui/animation1").play("snake2")


func _on_animation2_finished():
	get_node("ui/animation2").play("snake3")


func _on_animation3_finished():
	get_node("ui/animation3").play("whirl")


func spawn_fader(ttl = 2):
	if fader_spawned:
		return
	fader_spawned = true
	fader = fader_class.instance()
	fader.set_z(101)
	fader.set_scale(Vector2(10000,10000))
	fader.ttl = ttl
	add_child(fader)
	fader.connect("faded", self, "on_faded")
	pass

func on_faded():
	get_node("/root/global").start_game()
	# get_node("/root/global").tools()
	fader_spawned = false
	fader.queue_free()

func _on_btn_settings_pressed():
	if btns_enabled:
		own_state.settings_pressed()


func _on_settings_changed():
	if btns_enabled:
		own_state.settings_changed()


func _on_enable_buttons_timeout():
	btns_enabled = true
	pass # replace with function body
