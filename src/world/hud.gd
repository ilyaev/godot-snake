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

var lock_texture = preload("res://art/sprites/lock_big.png")
var unlock_texture = preload("res://art/sprites/unlock_big.png")

var hidable = []

var original_height = 0
var score = "0"
var experience = "0"
var cur_offset
var fader_spawned = false
var fader

func _ready():
	world.hide()
	get_node("ui").hide()
	original_height = ui.get_size().y

	var shower = fader_class.instance()
	shower.set_z(101)
	shower.set_scale(Vector2(10000,10000))
	shower.ttl = 1
	shower.invert = true
	add_child(shower)
	shower.connect("faded", self, "on_showed", [shower])

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
	pass

func on_showed(obj):
	obj.queue_free()

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


func hide_controls():
	bottom_left.hide()
	bottom_right.hide()

func show_controls():
	bottom_left.show()
	bottom_right.show()

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
