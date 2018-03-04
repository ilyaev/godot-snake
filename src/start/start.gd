extends "res://src/base-scene.gd"


var width = 640 * 2
var height = 480 * 2
var original_zoom
var field_height
var fader_spawned = false
var fader = false

onready var camera = get_node("camera")
onready var ui = get_node("ui")
onready var player = get_node("ui/animation")
onready var fader_class = preload('res://src/world/fader.tscn')

func _ready():
	field_height = height
	original_zoom = camera.get_zoom()
	size_changed()
	get_tree().get_root().connect("size_changed", self, "size_changed")
	ui.get_node("btn_start").set_default_cursor_shape(Control.CURSOR_POINTING_HAND)
	set_process(true)
	set_process_input(true)

func _input(event):
	if event.is_pressed():
		_on_tbtn_start_pressed()

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
	spawn_fader(0.5)


func _on_tbtn_start_pressed():
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