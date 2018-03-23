extends CanvasLayer

onready var ui = get_node("ui")
onready var world = get_node("/root/world")
onready var label_score = get_node("ui/top_right/score")
onready var label_lifes = get_node("ui/top_right/lifes")
onready var label_experience = get_node("ui/top_left/score")
onready var label_locks = get_node("ui/top_right/locks_count")
onready var sprite_locks = get_node("ui/top_right/locks")
onready var score_animation = get_node("ui/top_right/animation")
onready var bottom_left = get_node("ui/bottom_left")
onready var bottom_right = get_node("ui/bottom_right")
onready var top_left = get_node("ui/top_left")
onready var top_right = get_node("ui/top_right")
onready var animation = get_node("ui/animation")
onready var fader_class = preload('res://src/world/fader.tscn')
onready var global = get_node("/root/global")

onready var dpad_class = preload('res://src/world/controls/dpad.tscn')
onready var slider_class = preload('res://src/world/controls/slider.tscn')

var lock_texture = preload("res://art/sprites/lock_big.png")
var unlock_texture = preload("res://art/sprites/unlock_big.png")

var hidable = []

var original_height = 0
var score = "0"
var experience = "0"
var cur_offset
var fader_spawned = false
var fader
var bl_pos
var br_pos

var perf_initial = 0

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		global.perf.objects = perf_initial

func _ready():
	world.hide()
	perf_initial = Performance.get_monitor(Performance.OBJECT_COUNT)
	get_node("ui").hide()
	original_height = ui.get_size().y

	var shower = fader_class.instance()
	shower.set_z(101)
	shower.set_scale(Vector2(10000,10000))
	shower.ttl = 1
	shower.invert = true
	add_child(shower)
	shower.connect("faded", self, "on_showed", [shower])
	set_fixed_process(true)

	label_score.set_text("2")
	label_lifes.set_text("3")
	hidable = [
		{
			'component': bottom_left,
			'animation': "bottom_left_visibility"
		},
		{
			'component': top_left,
			'animation': "top_left_visibility"
		},
		{
			'component': top_right,
			'animation': "top_right_visibility"
		},
		{
			'component': bottom_right,
			'animation': "bottom_right_visibility"
		}
	]
	bottom_left.hide()
	bottom_right.hide()

	set_control_style()


func set_control_style():
	for one in bottom_left.get_children():
		one.queue_free()
	for one in bottom_right.get_children():
		one.queue_free()

	var os = OS.get_name()
	if os == 'OSX' or os == 'Windows':
		return


	var control = dpad_class.instance()
	var control2 = dpad_class.instance()

	if global.get_control_style() == "1":
		control = slider_class.instance()
		control2 = slider_class.instance()

	control.set_centered(true)
	control.set_pos(Vector2(230,225))
	control.connect("command", self, "_on_gamepad_command")

	control2.set_centered(true)
	control2.set_pos(Vector2(230,210))
	control2.connect("command", self, "_on_gamepad_command")

	bottom_left.add_child(control)
	bottom_right.add_child(control2)

	# var control =

func on_showed(obj):
	show_controls()
	obj.queue_free()

func _fixed_process(delta):
	pass
	# top_left.get_node("fps").set_text("FPS: " + str(OS.get_frames_per_second()) + ' / ' + str(perf_initial) + ' / +' + str(perf_initial - global.perf.objects) + ' / ' + str(Performance.get_monitor(Performance.OBJECT_COUNT)))

func rescale(zoom, offset):
	offset.x = min(0, offset.x)
	offset.y = min(0, offset.y)
	cur_offset = offset
	var size = get_tree().get_root().get_children()[1].get_viewport_rect().size
	size.x = (size.x + (offset.x * 2 / zoom.x)) * zoom.x
	size.y = size.y * zoom.y
	ui.set_size(size)
	ui.set_scale(Vector2(1,1) / zoom)
	ui.set_pos((offset / zoom) * -1)

	bl_pos = bottom_left.get_pos()
	br_pos = bottom_right.get_pos()


func hide_controls():
	tween_hide(bottom_left, bl_pos)
	tween_hide(bottom_right, br_pos)

func show_controls():
	tween_show(bottom_left, bl_pos)
	tween_show(bottom_right, br_pos)

func tween_show(component, origin):
	var shift = Vector2(0, 500)
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(component, "rect/pos", origin + shift, origin, 0.1 + randf() * 0.4, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.connect("tween_complete", self, "tween_complete", [tween])
	tween.start()
	component.set_pos(origin + shift)
	component.show()

func tween_hide(component, origin):
	var shift = Vector2(0, 500)
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(component, "rect/pos", origin, origin + shift, 0.3 + randf() * 0.4, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.connect("tween_complete", self, "tween_complete", [tween])
	tween.start()

func tween_complete(obj, key, tween):
	print("Quet Tween")
	tween.queue_free()



func get_center():
	return ui.get_size() / 2

func add_to_center(scene):
	scene.set_pos(get_center())
	ui.add_child(scene)

func set_lifes(lifes):
	if label_lifes.get_text() != lifes:
		score_animation.play("life")
	label_lifes.set_text(lifes)

func set_locks(locks):
	if label_locks.get_text() != locks:
		if locks == "0":
			sprite_locks.set_texture(unlock_texture)
			label_locks.hide()
			print("OPEN PORTAL")
		elif label_locks.get_text() == "0":
			sprite_locks.set_texture(lock_texture)
			label_locks.show()
			print("CLOSE PORTAL")
	label_locks.set_text(locks)

func update_score(new_score, new_experience):
	if new_score == score and new_experience == experience:
		return
	score_animation.play("label")
	score = new_score
	experience = new_experience
	label_score.set_text(score)
	label_experience.set_text(experience)

func spawn_fader(ttl = 2, invert = false):
	if fader_spawned:
		return
	fader_spawned = true
	fader = fader_class.instance()
	fader.invert = invert
	fader.set_z(101)
	fader.set_scale(world.camera.size)
	fader.ttl = ttl
	add_child(fader)
	pass

func release_fader():
	if fader_spawned:
		fader_spawned = false
		fader.queue_free()

func update_player_position(pos, offset,map_pos, maxX, maxY):
	var screen = pos - offset

	for one in hidable:
		var rect = Rect2(one.component.get_pos(), one.component.get_size())
		if rect.has_point(screen):
			if one.component.get_opacity() == 1:
				animation.play(one.animation)
		else:
			if one.component.get_opacity() < 1 and !animation.is_playing():
				animation.play_backwards(one.animation)


func _on_Timer_timeout():
	world.show()
	get_node("ui").show()


func _on_gamepad_command(cmd):
	world.ui_command(cmd)
